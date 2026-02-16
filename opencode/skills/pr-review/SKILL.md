---
name: pr-review
description: Fetch open GitHub PR data (diff, files, CI, metadata), perform AI code review using strict KISS/DRY/SOLID rules, save results locally, and present categorized findings. Trigger - any GitHub PR URL or request to "review PR", "check PR", "review open PR".
---

## What I do

Perform end-to-end AI code review of GitHub Pull Requests:
1. Fetch PR data (diff, files, metadata, CI status, existing reviews) via a bundled Python script
2. Analyze each changed file against strict code review rules
3. Categorize findings by severity
4. Save results locally (JSON + Markdown) for persistent analysis
5. Present structured review report
6. Optionally: post comments to GitHub or apply fixes

## When to use me

- User shares a GitHub PR URL and wants a code review
- User asks to "review PR", "check PR code", "review open PR"
- User wants to analyze PR quality before merging
- User wants to compare reviews across multiple PRs (saved locally)

## WORKFLOW

### STEP 1: Fetch PR data

Run the bundled script. It handles URL parsing, GraphQL + REST queries, filtering, chunking, and saves data locally:

```bash
python3 ~/.config/opencode/skills/pr-review/fetch-pr-data.py <PR_REFERENCE>
```

Supported input formats:
- `https://github.com/owner/repo/pull/123`
- `owner/repo#123`
- `owner/repo 123`
- Just `123` (infers owner/repo from current git repo)

The script **automatically**:
- **Filters out** lock files, generated code, vendor dirs, minified files, source maps, snapshots
- **Prioritizes** source code (.ts/.py/.go/etc) over config over docs/assets
- **Truncates** PR body to 500 chars (configurable via `--max-body`)
- **Removes diff duplication** (only `file_patches` with per-file patches, no full unified diff)
- **Chunks large PRs** into groups of 20 files (configurable via `--chunk-size`)

Output JSON saved to `~/.local/share/opencode/pr-reviews/`:
```json
{
  "repo": "owner/repo",
  "pr_number": 123,
  "title": "Add auth middleware",
  "body": "PR description (truncated)...",
  "stats": {
    "additions": 150, "deletions": 30, "changed_files": 25,
    "reviewable_files": 20, "skipped_files": 5,
    "total_review_tokens_est": 35000
  },
  "ci": { "state": "SUCCESS", "checks": [...] },
  "reviews": [...],
  "skipped_files": ["package-lock.json", "dist/bundle.min.js"],
  "chunking": {
    "total_chunks": 2,
    "chunk_size": 20,
    "chunks": [
      { "chunk": 1, "files": 20, "tokens_est": 25000, "file_paths": [...] },
      { "chunk": 2, "files": 5,  "tokens_est": 10000, "file_paths": [...] }
    ]
  },
  "file_patches": [...]
}
```

**If PR fits in 1 chunk** (≤20 files, ~40k tokens): `file_patches` is included inline — proceed to STEP 2.
**If PR needs multiple chunks**: `file_patches` is NOT included. Use chunked workflow (see STEP 1b).

If the script fails with auth error, tell user to run `gh auth login`.
If the PR is a draft, warn the user and ask if they still want to review.

### STEP 1b: Chunked review (large PRs only)

When `chunking.total_chunks > 1`, review chunk-by-chunk:

```bash
python3 ~/.config/opencode/skills/pr-review/fetch-pr-data.py <PR_REFERENCE> --chunk 1
python3 ~/.config/opencode/skills/pr-review/fetch-pr-data.py <PR_REFERENCE> --chunk 2
```

Each chunk returns only its file patches:
```json
{
  "chunk": 1,
  "total_chunks": 3,
  "files_in_chunk": 20,
  "tokens_est": 25000,
  "file_patches": [...]
}
```

**Chunked workflow**:
1. Run script without `--chunk` — get metadata + chunking plan
2. For each chunk N (1 to total_chunks):
   a. Run script with `--chunk N` — get file patches for this chunk
   b. Review this chunk's files (STEP 3)
   c. Collect findings
3. After all chunks: merge findings, deduplicate cross-file issues, proceed to STEP 4

**Important**: When reviewing chunks, keep the metadata from step 1 in context (CI status, PR description, existing reviews). Only the file_patches change per chunk.

### STEP 2: Pre-review context

Before reviewing, gather context:

1. **Read PR description** (`body`) — understand the intent and scope
2. **Check CI status** — note failures, they may indicate broken code
3. **Check existing reviews** — note previous reviewer feedback
4. **Check unresolved threads** — avoid duplicating existing feedback
5. **Scan file list** — identify the scope (frontend, backend, infra, tests)
6. **If the project has AGENTS.md** — read it to understand project-specific rules and conventions

### STEP 3: Review each changed file

For each file in `file_patches`, analyze the `patch` (diff) against the review rules.

#### REVIEW RULES (HARD — from project code-reviewer config)

**Code structure:**
- No large functions: max 20–30 LOC or 1 clear responsibility. Split otherwise.
- No `else` statements: use guard clauses / early returns / fail fast. (except css/scss files)
- No `switch`/`case`: prefer polymorphism, strategy/command pattern, or data maps.
- No dead code, no TODOs, no unused params/imports, no magic numbers (extract constants).
- Maximum nesting depth: target 1, max 2. Extract nested logic to functions.

**Principles:**
- Pure, side-effect-free logic where feasible; isolate I/O.
- Strong, descriptive naming; single source of truth (DRY).
- SOLID: SRP, Open/Closed via composition; Liskov-safe subs; Interface Segregation; Dependency Inversion.
- Clear module boundaries; small files; private by default.
- Composition over inheritance. Functional-first approach.
- Immutable data where practical.

**Error handling:**
- Explicit, typed where applicable; no silent catches; meaningful messages.
- Propagate or handle at boundaries. Fail fast.

**Security:**
- Validate inputs, avoid injection, safe defaults, least privilege, no secrets/hardcoding.
- Output encoding, parameterized queries, no eval/innerHTML with untrusted data.

**Performance:**
- Avoid premature micro-opts; watch N+1, needless allocations, blocking I/O on hot paths.
- Batch related queries, memoize expensive pure computations.

**Tests:**
- Require unit/behavior tests for branches; deterministic; fast; edge cases covered.

**Style:**
- Idiomatic style for the language; consistent lint rules; zero warnings.
- Minimize comments — code must be self-documenting through clear naming.

#### REVIEW FOCUS (ordered by importance)

1. **Bugs & Logic errors** — will this code break in production?
2. **Security vulnerabilities** — injection, auth bypass, data leaks
3. **Error handling gaps** — unhandled failures, silent catches
4. **Architecture violations** — SOLID, DRY, coupling issues
5. **Performance problems** — N+1, blocking I/O, memory leaks
6. **Code quality** — function size, nesting, naming, dead code
7. **Test coverage** — missing tests for new logic
8. **Style & consistency** — formatting, naming conventions

### STEP 4: Categorize findings

Group all findings into severity categories:

- **CRITICAL** — Blocking: bugs, security vulns, data loss risks, broken functionality
- **MAJOR** — Should fix: architecture violations, missing error handling, performance issues, missing tests
- **MINOR** — Nice to fix: style, naming, code quality improvements, minor DRY violations
- **INFO** — Observations: positive patterns noticed, architectural notes, suggestions for future

### STEP 5: Save results locally

Save the review in two formats:

#### JSON (for programmatic analysis):

Save to `~/.local/share/opencode/pr-reviews/{owner}_{repo}_{pr_number}_review.json`:

```json
{
  "reviewed_at": "2026-02-16T17:33:04Z",
  "repo": "owner/repo",
  "pr_number": 123,
  "pr_url": "https://github.com/owner/repo/pull/123",
  "title": "PR title",
  "author": "developer",
  "stats": { "additions": 150, "deletions": 30, "changed_files": 5 },
  "ci_state": "SUCCESS",
  "verdict": "CHANGES_REQUESTED",
  "summary": "One paragraph summary...",
  "findings": [
    {
      "severity": "critical",
      "category": "security",
      "file": "src/auth.ts",
      "line": 42,
      "title": "SQL injection via unsanitized input",
      "description": "User input passed directly to query without parameterization",
      "suggestion": "Use parameterized query: db.query('SELECT * FROM users WHERE id = $1', [userId])"
    }
  ],
  "finding_counts": {
    "critical": 1,
    "major": 3,
    "minor": 5,
    "info": 2
  },
  "files_reviewed": 5
}
```

#### Markdown (for human reading):

Save to `~/.local/share/opencode/pr-reviews/{owner}_{repo}_{pr_number}_review.md`.

Use the OUTPUT FORMAT from Step 6.

### STEP 6: Present review to user

Use this STRICT output format:

```
## PR Review: {TITLE}
**URL**: {PR_URL}
**Author**: @{AUTHOR} | **Branch**: {HEAD} → {BASE}
**Stats**: +{ADDITIONS} -{DELETIONS} across {CHANGED_FILES} files
**CI**: {CI_STATE} | **Existing reviews**: {REVIEW_COUNT}
**Verdict**: {APPROVE | CHANGES_REQUESTED | COMMENT}

---

### 1) Summary
One concise paragraph of the biggest issues and the overall direction.

### 2) Critical Issues ({COUNT})

#### [{N}] {FILE}:{LINE} — {TITLE}
**Category**: {security|bug|data-loss}
> {description of the issue}
**Fix**: {specific fix with code if needed}

### 3) Major Issues ({COUNT})

#### [{N}] {FILE}:{LINE} — {TITLE}
**Category**: {architecture|error-handling|performance|testing}
> {description}
**Fix**: {specific fix}

### 4) Minor / Style ({COUNT})
- [{N}] {FILE}:{LINE} — {short description} → {fix}

### 5) Security & Robustness
- Input validation: {assessment}
- Error handling: {assessment}
- Resource cleanup: {assessment}
- Race conditions: {assessment}

### 6) Proposed Refactor (≤5 steps)
1. {step 1}
2. {step 2}
...

### 7) Tests to Add
- `{testName}`: {what it asserts}

### 8) Positive Patterns
- {what's done well — acknowledge good code}

---

**Saved to**: `{path_to_json}` and `{path_to_md}`
```

### STEP 7: Ask for action

```
What would you like to do?
- "post" — post findings as PR review comments on GitHub
- "fix N,N,N" — apply fixes for specific findings (by number)
- "fix all" — fix all critical + major issues
- "compare" — compare with previous review of this PR
- "done" — review complete, no further action
```

Wait for user response. Do NOT proceed without explicit instruction.

### STEP 8: Execute action (if requested)

#### If "post":
Post review via `gh api` as a single review with inline comments:
```bash
gh api /repos/{owner}/{repo}/pulls/{pr}/reviews \
  -f commit_id='{head_sha}' \
  -f event='COMMENT' \
  -f body='AI Review Summary...' \
  -f comments[][path]='file.ts' \
  -F comments[][line]=42 \
  -f comments[][body]='Finding description'
```

#### If "fix":
1. Checkout the PR branch: `gh pr checkout {pr_number}`
2. For each selected finding, read the file and apply minimal fix
3. Run `lsp_diagnostics` on changed files
4. Report what was fixed

#### If "compare":
Load previous review from `~/.local/share/opencode/pr-reviews/` and diff findings.

## Hard rules

- NEVER push changes without explicit user permission
- NEVER approve/dismiss reviews on GitHub without explicit user permission
- NEVER modify files not mentioned in the PR diff
- NEVER ignore AGENTS.md / project-specific rules if the project has them
- If `gh` is not authenticated — tell user to run `gh auth login` and stop
- Answer in the same language the user uses
- Review ONLY the diff — don't critique pre-existing code outside the PR scope
- Be objective: acknowledge good patterns, don't only criticize
- Focus on impact: a real bug > 10 style nitpicks

## Context budget

The script estimates token usage and reports it in `stats.total_review_tokens_est`.

| PR size | Tokens est | Strategy |
|---------|-----------|----------|
| ≤20 files, <40k tokens | ~5-40k | Single pass (default) |
| 20-100 files, 40-200k tokens | ~40-200k | Chunked (auto) |
| >100 files | >200k | Chunked + consider `--chunk-size 15` for tighter chunks |

Adjust chunk size if needed: `--chunk-size 15` for large patches, `--chunk-size 30` for small ones.

## Viewing saved reviews

All reviews are saved persistently in `~/.local/share/opencode/pr-reviews/`:
- `{owner}_{repo}_{pr}_review.json` — structured data
- `{owner}_{repo}_{pr}_review.md` — human-readable report
- `{owner}_{repo}_{pr}.json` — raw PR data from fetch
- `{owner}_{repo}_{pr}_chunkN.json` — chunk data (large PRs)

To list saved reviews:
```bash
ls -la ~/.local/share/opencode/pr-reviews/
```

To re-analyze a previously fetched PR without re-fetching:
```bash
cat ~/.local/share/opencode/pr-reviews/{owner}_{repo}_{pr}.json
```
