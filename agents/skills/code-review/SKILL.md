---
name: code-review
description: Reviews uncommitted changes or an explicitly requested diff with a strict KISS/DRY/SOLID rubric. Use when the user asks for a code review, diff review, pre-commit validation, or a quality pass on recent changes.
---

# Code Review

Use this skill for review-only work.

## Canonical Review Rubric

Before reviewing, load the canonical reviewer policy:

- `references/code-reviewer.md`

Treat that file as the source of truth for:
- review rules
- severity model
- output format
- language behavior

## Default Scope

Unless the user specifies another scope, review only uncommitted changes:

```bash
git diff HEAD --name-only
git diff HEAD -- <file>
```

If the user gives a commit, branch, file list, or patch range, use that scope instead.

If there is no diff, say so clearly and stop.

## Review Workflow

1. Determine the exact review scope.
2. Read only the changed files and the minimum nearby context needed to judge correctness.
3. Apply the rubric from `references/code-reviewer.md` strictly.
4. Focus on correctness first, then maintainability, then style.
5. Call out missing tests and edge cases explicitly.
6. Respond in the same language as the user's request.

## Constraints

- Do not implement fixes unless the user explicitly asks for them.
- Do not review unrelated files.
- Prefer precise, actionable findings over broad opinions.
- Merge duplicate findings.

## Output

Follow the output structure defined in `references/code-reviewer.md`.
