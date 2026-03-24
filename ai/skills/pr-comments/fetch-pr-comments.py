#!/usr/bin/env python3
"""Fetch unresolved PR review comments via GitHub GraphQL API.

Usage:
    fetch-pr-comments.py https://github.com/owner/repo/pull/123
    fetch-pr-comments.py owner/repo 123
    fetch-pr-comments.py 123                  # infers owner/repo from current git repo
    fetch-pr-comments.py owner/repo#123

Outputs JSON array of unresolved review threads to stdout.
Requires: gh CLI authenticated (`gh auth login`).
"""

import json
import re
import subprocess
import sys

QUERY = """
query FetchReviewThreads($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      title
      url
      reviewThreads(first: 100) {
        totalCount
        edges {
          node {
            id
            isResolved
            isOutdated
            path
            line
            startLine
            comments(first: 50) {
              nodes {
                author { login }
                body
                url
                createdAt
                diffHunk
              }
            }
          }
        }
      }
    }
  }
}
"""


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error running {' '.join(cmd)}:\n{result.stderr}", file=sys.stderr)
        sys.exit(1)
    return result.stdout.strip()


def infer_repo() -> str:
    return run(
        ["gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"]
    )


def parse_args(args: list[str]) -> tuple[str, str, int]:
    text = " ".join(args)

    # https://github.com/owner/repo/pull/123
    m = re.search(r"github\.com/([^/]+)/([^/]+)/pull/(\d+)", text)
    if m:
        return m.group(1), m.group(2), int(m.group(3))

    # owner/repo#123
    m = re.match(r"^([^/]+)/([^#]+)#(\d+)$", text.strip())
    if m:
        return m.group(1), m.group(2), int(m.group(3))

    # owner/repo 123
    if len(args) == 2:
        m = re.match(r"^([^/]+)/(.+)$", args[0])
        if m and args[1].isdigit():
            return m.group(1), m.group(2), int(args[1])

    # just a number — infer repo
    if len(args) == 1 and args[0].isdigit():
        repo = infer_repo()
        owner, name = repo.split("/")
        return owner, name, int(args[0])

    print(
        "Usage: fetch-pr-comments.py <pr-url | owner/repo#N | owner/repo N | N>",
        file=sys.stderr,
    )
    sys.exit(1)


def fetch_threads(owner: str, repo: str, pr: int) -> dict:
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
            f"query={QUERY}",
        ]
    )
    return json.loads(raw)


def main() -> None:
    if len(sys.argv) < 2:
        print(
            "Usage: fetch-pr-comments.py <pr-url | owner/repo#N | owner/repo N | N>",
            file=sys.stderr,
        )
        sys.exit(1)

    owner, repo, pr = parse_args(sys.argv[1:])
    data = fetch_threads(owner, repo, pr)

    pr_data = data["data"]["repository"]["pullRequest"]
    threads = pr_data["reviewThreads"]["edges"]

    unresolved = [edge["node"] for edge in threads if not edge["node"]["isResolved"]]

    output = {
        "pr_title": pr_data["title"],
        "pr_url": pr_data["url"],
        "total_threads": pr_data["reviewThreads"]["totalCount"],
        "unresolved_count": len(unresolved),
        "unresolved_threads": unresolved,
    }

    print(json.dumps(output, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
