---
name: pr-comments
description: Fetch unresolved GitHub PR review comments, analyze each for relevance, present categorized summary, ask which to fix, then apply minimal code changes. Trigger - any GitHub PR URL or request to review/fix PR comments.
---

## What I do

Process GitHub Pull Request review feedback end-to-end:
1. Fetch unresolved review threads via a bundled Python script
2. Classify each comment: actionable, question, outdated, nitpick, or invalid
3. Present a structured summary grouped by category
4. Ask which comments to fix
5. Apply minimal targeted fixes
6. Report results with diagnostics

## When to use me

- User shares a GitHub PR URL and wants to address review comments
- User asks to "fix PR review", "check PR comments", "handle review feedback"
- User wants a summary of what reviewers requested

## WORKFLOW

### STEP 1: Fetch unresolved threads

Run the bundled script. It handles URL parsing, GraphQL query, and filters to unresolved only:

```bash
python3 ~/.config/opencode/skills/pr-comments/fetch-pr-comments.py <PR_REFERENCE>
```

Supported input formats:
- `https://github.com/owner/repo/pull/123`
- `owner/repo#123`
- `owner/repo 123`
- Just `123` (infers owner/repo from current git repo)

The script outputs JSON:
```json
{
  "pr_title": "Fix auth flow",
  "pr_url": "https://github.com/...",
  "total_threads": 12,
  "unresolved_count": 5,
  "unresolved_threads": [
    {
      "id": "PRRT_...",
      "isOutdated": false,
      "path": "src/auth.ts",
      "line": 42,
      "comments": {
        "nodes": [
          {
            "author": { "login": "reviewer" },
            "body": "Add null check here",
            "url": "https://github.com/...",
            "diffHunk": "@@ -40,6 +40,8 @@..."
          }
        ]
      }
    }
  ]
}
```

If `unresolved_count` is 0, tell the user and stop.
If the script fails with auth error, tell the user to run `gh auth login`.

### STEP 2: Classify each unresolved comment

For each thread:

1. **Actionable?** — requests a specific code change vs question/praise/discussion
2. **Outdated?** — check `isOutdated` flag AND compare `diffHunk` with current file content. If code already changed, mark as already-fixed
3. **Relevant?** — real issue or bike-shedding?

Categories:
- **ACTIONABLE** — requires a code change
- **QUESTION** — reviewer asks for clarification, no code change
- **OUTDATED** — code already changed or references deleted code
- **NITPICK** — style preference, not a real problem
- **INVALID** — suggestion is incorrect or would introduce a bug

### STEP 3: Present summary

```
## PR Review Summary: {PR_TITLE}
**URL**: {PR_URL}
**Unresolved threads**: {TOTAL} ({ACTIONABLE_COUNT} actionable)

### Actionable

#### [1] {FILE_PATH}:{LINE} — @{AUTHOR}
> {COMMENT_BODY}
**Assessment**: {why actionable — 1 sentence}

### Questions (need response, not code)
- [N] {FILE_PATH}:{LINE} — @{AUTHOR}: {short summary}

### Can be dismissed
- [N] {FILE_PATH}:{LINE} — {OUTDATED|NITPICK|INVALID}: {reason}
```

### STEP 4: Ask what to fix

```
Which comments should I fix?
- "all" — fix all actionable
- Comma-separated numbers (e.g. "1, 3, 5") — specific ones
- "none" — summary only
```

Wait for user response. Do NOT proceed without explicit instruction.

### STEP 5: Apply fixes

For each selected comment:
1. Read the file from `path` field
2. Study `diffHunk` for context
3. Read the FULL comment thread (all replies) to understand complete discussion
4. Make the minimal change addressing the reviewer's concern
5. Run `lsp_diagnostics` on the changed file

Rules:
- Minimal changes only — exactly what the reviewer asks
- Never refactor surrounding code
- Preserve file's existing code style
- If fix is ambiguous — ask the user
- If fix would break other code — warn and ask for confirmation

### STEP 6: Report

```
## Fixes Applied

| # | File | Line | Status | What changed |
|---|------|------|--------|-------------|
| 1 | src/foo.ts | 42 | Fixed | Renamed variable per reviewer |
| 3 | src/bar.ts | 15 | Fixed | Added null check |

**Files changed**: {list}
**Diagnostics**: {clean / N warnings}
```

Do NOT commit. User reviews and commits manually.

## Hard rules

- NEVER resolve review threads on GitHub
- NEVER push changes
- NEVER modify files not mentioned in review comments
- If `gh` is not authenticated — tell user to run `gh auth login` and stop
- Answer in the same language the user uses
