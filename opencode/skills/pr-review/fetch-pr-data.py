#!/usr/bin/env python3
"""Fetch PR data for AI code review via GitHub GraphQL + REST API.

Usage:
    fetch-pr-data.py <PR_REFERENCE> [OPTIONS]

    fetch-pr-data.py https://github.com/owner/repo/pull/123
    fetch-pr-data.py owner/repo#123
    fetch-pr-data.py owner/repo 123
    fetch-pr-data.py 123                    # infers owner/repo from current git repo

Options:
    --chunk N       Output only chunk N (1-based). Omit for metadata + file list
                    (includes patches inline if PR fits in 1 chunk).
    --chunk-size N  Max files per chunk (default: 20).
    --max-body N    Truncate PR body to N chars (default: 500).
    --no-save       Don't save to disk, only print to stdout.

Outputs JSON with PR metadata, file patches (per-chunk), CI status, and reviews.
Requires: gh CLI authenticated (`gh auth login`).
"""

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

GRAPHQL_QUERY = """
query FetchPRData($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      title
      body
      url
      state
      number
      isDraft
      headRefName
      baseRefName
      headRefOid
      baseRefOid
      mergeable
      reviewDecision
      additions
      deletions
      changedFiles
      author { login }
      labels(first: 20) { nodes { name } }
      commits(last: 1) {
        nodes {
          commit {
            oid
            statusCheckRollup {
              state
              contexts(first: 30) {
                nodes {
                  ... on CheckRun {
                    __typename
                    name
                    status
                    conclusion
                    detailsUrl
                  }
                  ... on StatusContext {
                    __typename
                    context
                    state
                    targetUrl
                  }
                }
              }
            }
          }
        }
      }
      reviews(last: 20) {
        nodes {
          author { login }
          state
          body
          submittedAt
        }
      }
      reviewThreads(first: 100) {
        totalCount
        nodes {
          isResolved
          isOutdated
          path
          line
          comments(first: 10) {
            nodes {
              author { login }
              body
              createdAt
            }
          }
        }
      }
      files(first: 100) {
        totalCount
        nodes {
          path
          additions
          deletions
          changeType
        }
      }
    }
  }
}
"""

REVIEWS_DIR = Path.home() / ".local" / "share" / "opencode" / "pr-reviews"

SKIP_PATTERNS = [
    r"(^|/)package-lock\.json$",
    r"(^|/)yarn\.lock$",
    r"(^|/)pnpm-lock\.yaml$",
    r"(^|/)bun\.lock(b)?$",
    r"(^|/)Cargo\.lock$",
    r"(^|/)Gemfile\.lock$",
    r"(^|/)poetry\.lock$",
    r"(^|/)composer\.lock$",
    r"(^|/)go\.sum$",
    r"(^|/)Pipfile\.lock$",
    r"(^|/)flake\.lock$",
    r"(^|/)\.yarn/",
    r"(^|/)vendor/",
    r"(^|/)node_modules/",
    r"(^|/)dist/",
    r"(^|/)build/",
    r"(^|/)\.next/",
    r"\.min\.(js|css)$",
    r"\.map$",
    r"\.snap$",
    r"\.generated\.",
    r"__generated__",
    r"(^|/)codegen/",
]

SKIP_RE = re.compile("|".join(SKIP_PATTERNS))

PRIORITY_HIGH = {
    ".ts",
    ".tsx",
    ".js",
    ".jsx",
    ".py",
    ".go",
    ".rs",
    ".java",
    ".rb",
    ".vue",
    ".svelte",
    ".kt",
    ".swift",
    ".c",
    ".cpp",
    ".h",
}
PRIORITY_MED = {
    ".css",
    ".scss",
    ".html",
    ".sql",
    ".sh",
    ".yaml",
    ".yml",
    ".toml",
    ".graphql",
    ".proto",
}
PRIORITY_LOW = {".md", ".txt", ".json", ".xml", ".svg", ".png", ".jpg", ".ico"}


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error running {cmd[0]}...:\n{result.stderr}", file=sys.stderr)
        sys.exit(1)
    return result.stdout.strip()


def infer_repo() -> str:
    return run(
        ["gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"]
    )


def parse_pr_ref(args: list[str]) -> tuple[str, str, int]:
    text = " ".join(args)

    m = re.search(r"github\.com/([^/]+)/([^/]+)/pull/(\d+)", text)
    if m:
        return m.group(1), m.group(2), int(m.group(3))

    m = re.match(r"^([^/]+)/([^#]+)#(\d+)$", text.strip())
    if m:
        return m.group(1), m.group(2), int(m.group(3))

    if len(args) >= 2:
        m = re.match(r"^([^/]+)/(.+)$", args[0])
        if m and args[1].isdigit():
            return m.group(1), m.group(2), int(args[1])

    if len(args) >= 1 and args[0].isdigit():
        repo = infer_repo()
        owner, name = repo.split("/")
        return owner, name, int(args[0])

    print(
        "Usage: fetch-pr-data.py <pr-url | owner/repo#N | owner/repo N | N> [OPTIONS]",
        file=sys.stderr,
    )
    sys.exit(1)


def fetch_graphql(owner: str, repo: str, pr: int) -> dict:
    raw = run(
        [
            "gh",
            "api",
            "graphql",
            "-f",
            f"owner={owner}",
            "-f",
            f"repo={repo}",
            "-F",
            f"pr={pr}",
            "-f",
            f"query={GRAPHQL_QUERY}",
        ]
    )
    return json.loads(raw)


def fetch_file_patches(owner: str, repo: str, pr: int) -> list[dict]:
    raw = run(
        [
            "gh",
            "api",
            f"/repos/{owner}/{repo}/pulls/{pr}/files",
            "--paginate",
            "-q",
            "[.[] | {path: .filename, status: .status, patch: .patch, "
            "additions: .additions, deletions: .deletions}]",
        ]
    )
    results = []
    for line in raw.strip().split("\n"):
        if not line:
            continue
        parsed = json.loads(line)
        if isinstance(parsed, list):
            results.extend(parsed)
        else:
            results.append(parsed)
    return results


def is_skippable(path: str) -> bool:
    return bool(SKIP_RE.search(path))


def file_priority(path: str) -> int:
    ext = Path(path).suffix.lower()
    if ext in PRIORITY_HIGH:
        return 0
    if ext in PRIORITY_MED:
        return 1
    if ext in PRIORITY_LOW:
        return 2
    return 1


def filter_and_sort_patches(
    patches: list[dict],
) -> tuple[list[dict], list[dict]]:
    reviewable, skipped = [], []
    for p in patches:
        path = p.get("path", "")
        if is_skippable(path) or not p.get("patch"):
            skipped.append(p)
            continue
        reviewable.append(p)

    reviewable.sort(
        key=lambda p: (
            file_priority(p.get("path", "")),
            -(p.get("additions", 0) + p.get("deletions", 0)),
        )
    )
    return reviewable, skipped


def estimate_tokens(patches: list[dict]) -> int:
    return sum(len(p.get("patch") or "") for p in patches) // 4


def chunk_patches(patches: list[dict], size: int) -> list[list[dict]]:
    if not patches:
        return []
    return [patches[i : i + size] for i in range(0, len(patches), size)]


def truncate_body(body: str, max_len: int) -> str:
    if not body or len(body) <= max_len:
        return body or ""
    cut = body[:max_len].rsplit("\n", 1)[0]
    return cut + f"\n\n... [truncated, {len(body) - len(cut)} chars omitted]"


def extract_ci(pr_data: dict) -> dict:
    commits = pr_data.get("commits", {}).get("nodes") or []
    last = commits[-1]["commit"] if commits else {}
    rollup = last.get("statusCheckRollup") or {}

    checks = []
    for ctx in rollup.get("contexts", {}).get("nodes") or []:
        t = ctx.get("__typename")
        if t == "CheckRun":
            checks.append(
                {
                    "name": ctx.get("name"),
                    "status": ctx.get("status"),
                    "conclusion": ctx.get("conclusion"),
                }
            )
        elif t == "StatusContext":
            checks.append(
                {
                    "name": ctx.get("context"),
                    "status": ctx.get("state"),
                    "conclusion": ctx.get("state"),
                }
            )
    return {"state": rollup.get("state", "UNKNOWN"), "checks": checks}


def extract_reviews(pr_data: dict) -> list[dict]:
    return [
        {
            "author": r["author"]["login"] if r.get("author") else "unknown",
            "state": r.get("state"),
            "body": (r.get("body") or "")[:300],
        }
        for r in (pr_data.get("reviews", {}).get("nodes") or [])
    ]


def extract_unresolved_threads(pr_data: dict) -> list[dict]:
    threads = []
    for t in pr_data.get("reviewThreads", {}).get("nodes") or []:
        if t.get("isResolved"):
            continue
        comments = [
            {
                "author": c["author"]["login"] if c.get("author") else "unknown",
                "body": c.get("body", ""),
            }
            for c in (t.get("comments", {}).get("nodes") or [])
        ]
        threads.append(
            {
                "path": t.get("path"),
                "line": t.get("line"),
                "is_outdated": t.get("isOutdated", False),
                "comments": comments,
            }
        )
    return threads


def extract_file_list(pr_data: dict) -> list[dict]:
    return [
        {
            "path": f.get("path"),
            "change_type": f.get("changeType"),
            "additions": f.get("additions", 0),
            "deletions": f.get("deletions", 0),
        }
        for f in (pr_data.get("files", {}).get("nodes") or [])
    ]


def build_metadata(
    owner: str,
    repo: str,
    pr_number: int,
    pr_data: dict,
    reviewable: list[dict],
    skipped: list[dict],
    chunk_size: int,
    max_body: int,
) -> dict:
    labels = [n["name"] for n in (pr_data.get("labels", {}).get("nodes") or [])]
    chunks = chunk_patches(reviewable, chunk_size)
    total_tokens = estimate_tokens(reviewable)

    chunk_info = [
        {
            "chunk": i + 1,
            "files": len(ch),
            "tokens_est": estimate_tokens(ch),
            "file_paths": [p["path"] for p in ch],
        }
        for i, ch in enumerate(chunks)
    ]

    return {
        "fetched_at": datetime.now(timezone.utc).isoformat(),
        "repo": f"{owner}/{repo}",
        "pr_number": pr_number,
        "pr_url": pr_data.get("url", ""),
        "title": pr_data.get("title", ""),
        "body": truncate_body(pr_data.get("body", ""), max_body),
        "state": pr_data.get("state", ""),
        "is_draft": pr_data.get("isDraft", False),
        "author": pr_data["author"]["login"] if pr_data.get("author") else "unknown",
        "head_branch": pr_data.get("headRefName", ""),
        "base_branch": pr_data.get("baseRefName", ""),
        "head_sha": pr_data.get("headRefOid", ""),
        "mergeable": pr_data.get("mergeable", "UNKNOWN"),
        "review_decision": pr_data.get("reviewDecision"),
        "labels": labels,
        "stats": {
            "additions": pr_data.get("additions", 0),
            "deletions": pr_data.get("deletions", 0),
            "changed_files": pr_data.get("changedFiles", 0),
            "reviewable_files": len(reviewable),
            "skipped_files": len(skipped),
            "total_review_tokens_est": total_tokens,
        },
        "ci": extract_ci(pr_data),
        "reviews": extract_reviews(pr_data),
        "unresolved_threads": extract_unresolved_threads(pr_data),
        "files": extract_file_list(pr_data),
        "skipped_files": [p["path"] for p in skipped],
        "chunking": {
            "total_chunks": len(chunks),
            "chunk_size": chunk_size,
            "chunks": chunk_info,
        },
    }


def build_chunk(
    owner: str,
    repo: str,
    pr_number: int,
    pr_title: str,
    reviewable: list[dict],
    chunk_size: int,
    chunk_num: int,
) -> dict:
    chunks = chunk_patches(reviewable, chunk_size)

    if chunk_num < 1 or chunk_num > len(chunks):
        print(
            f"Error: chunk {chunk_num} out of range (1-{len(chunks)})",
            file=sys.stderr,
        )
        sys.exit(1)

    chunk = chunks[chunk_num - 1]
    return {
        "repo": f"{owner}/{repo}",
        "pr_number": pr_number,
        "title": pr_title,
        "chunk": chunk_num,
        "total_chunks": len(chunks),
        "files_in_chunk": len(chunk),
        "tokens_est": estimate_tokens(chunk),
        "file_patches": chunk,
    }


def save_json(data: dict, suffix: str) -> Path:
    REVIEWS_DIR.mkdir(parents=True, exist_ok=True)
    repo_slug = data["repo"].replace("/", "_")
    filename = f"{repo_slug}_{data['pr_number']}{suffix}.json"
    filepath = REVIEWS_DIR / filename
    filepath.write_text(
        json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return filepath


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch PR data for AI code review",
        usage="fetch-pr-data.py <pr-ref> [OPTIONS]",
    )
    parser.add_argument("pr_ref", nargs="+", help="PR reference")
    parser.add_argument(
        "--chunk",
        type=int,
        default=None,
        help="Output specific chunk (1-based)",
    )
    parser.add_argument(
        "--chunk-size",
        type=int,
        default=20,
        help="Max files per chunk (default: 20)",
    )
    parser.add_argument(
        "--max-body",
        type=int,
        default=500,
        help="Truncate PR body to N chars (default: 500)",
    )
    parser.add_argument(
        "--no-save",
        action="store_true",
        help="Don't save to disk",
    )

    args = parser.parse_args()
    owner, repo, pr_number = parse_pr_ref(args.pr_ref)

    print(f"Fetching PR #{pr_number} from {owner}/{repo}...", file=sys.stderr)
    graphql_data = fetch_graphql(owner, repo, pr_number)
    pr_data = graphql_data["data"]["repository"]["pullRequest"]

    print("Fetching file patches...", file=sys.stderr)
    all_patches = fetch_file_patches(owner, repo, pr_number)
    reviewable, skipped = filter_and_sort_patches(all_patches)

    total_tokens = estimate_tokens(reviewable)
    total_chunks = max(1, -(-len(reviewable) // args.chunk_size))

    print(
        f"Files: {len(reviewable)} reviewable, {len(skipped)} skipped | "
        f"~{total_tokens:,} tokens | {total_chunks} chunk(s)",
        file=sys.stderr,
    )

    if args.chunk is not None:
        output = build_chunk(
            owner,
            repo,
            pr_number,
            pr_data.get("title", ""),
            reviewable,
            args.chunk_size,
            args.chunk,
        )
        if not args.no_save:
            path = save_json(output, f"_chunk{args.chunk}")
            print(f"[Saved to {path}]", file=sys.stderr)
    else:
        output = build_metadata(
            owner,
            repo,
            pr_number,
            pr_data,
            reviewable,
            skipped,
            args.chunk_size,
            args.max_body,
        )
        if total_chunks == 1 and reviewable:
            output["file_patches"] = reviewable
        if not args.no_save:
            path = save_json(output, "")
            print(f"[Saved to {path}]", file=sys.stderr)

    print(json.dumps(output, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
