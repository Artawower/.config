---
name: jj-review
description: Reviews a Jujutsu (jj) revision range using the canonical KISS/DRY/SOLID rubric. Use when the user asks to review jj revisions, review a jj diff range, check quality of a jj commit stack, or do a pre-push review of jj changes. Triggers on "review my jj changes", "review this revision", "review commits from A to B", "jj code review", "review before push", "review jj range", "check jj diff quality".
---

# JJ Review

Code review for Jujutsu (jj) revision ranges. Uses the same rubric as the `code-review` skill — any changes to that rubric are automatically picked up here.

## Canonical Review Rubric

Load the shared rubric from the code-review skill:

- `../code-review/references/code-reviewer.md`

Treat that file as the source of truth for:
- review rules
- severity model
- output format
- language behavior

Do NOT duplicate the rubric here. Always read it fresh so changes propagate.

## Scope Resolution

The user specifies what to review. Parse their intent into a `--from` / `--to` pair using jj revsets.

### Default (no arguments)

Review the current working-copy revision:

```bash
jj diff --from @- --to @
```

If the revision is empty (no diff), report that and stop.

### Patterns

| User says | Resolves to | Explanation |
|-----------|-------------|-------------|
| _(nothing / default)_ | `--from @- --to @` | Current revision vs parent |
| `@` | `--from @- --to @` | Same as default |
| `<change-id>` | `--from <change-id>- --to <change-id>` | Single revision (parent of id to id) |
| `<a>..<b>` | `--from <a> --to <b>` | Explicit range: diff between two commits |
| `main..@` | `--from main --to @` | Everything after main up to working copy |
| `[bookmark-name]` | `--from main --to <bookmark-name>` | Shortcut: find bookmark, diff from main to its tip |
| `last N` | `--from @-~N --to @` | Last N revisions in the stack |

### Bookmark shortcut `[name]`

When the user provides a name in square brackets (e.g. `[VW-branch]`, `[feat-auth]`):

1. Resolve to a jj bookmark:
   ```bash
   jj bookmark list name
   ```
2. If found, set `--from main --to <bookmark-name>`.
3. If not found, try to match as a substring across all bookmarks and ask the user to clarify.
4. If no `main` bookmark exists, try `master`, `trunk`, or the default branch — use `jj git remote book` to discover.

### Multi-revision range

When the range covers multiple revisions (e.g. `main..@`), show the list first:

```bash
jj log -r '<from>::<to>'
```

This gives context on how many commits are being reviewed and their descriptions.

## Review Workflow

1. **Parse scope** — determine `--from` / `--to` from user input using the patterns above.
2. **Show what's in scope** — run `jj log -r '<from>::<to>'` to list revisions being reviewed. Report count.
3. **Get the diff** — run `jj diff --from <from> --to <to>` to get the full patch.
4. **List changed files** — run `jj diff --from <from> --to <to> --name-only` for the file list.
5. **Load the rubric** — read `../code-review/references/code-reviewer.md`.
6. **Read context** — load the changed files and minimum surrounding context needed to judge correctness. Do not load the entire codebase.
7. **Apply rubric strictly** — follow the severity model and rules from the rubric.
8. **For multi-revision ranges** — optionally group findings per revision when a finding is clearly tied to a specific commit. But keep the overall report unified; do not produce N separate reports.
9. **Respond in the same language as the user's request.**

## Constraints

- Do not implement fixes unless the user explicitly asks for them.
- Do not review files outside the diff scope.
- Prefer precise, actionable findings over broad opinions.
- Merge duplicate findings.
- If a revision in the range is empty, skip it and note that it was empty.

## Output

Follow the output structure defined in `../code-review/references/code-reviewer.md`.
