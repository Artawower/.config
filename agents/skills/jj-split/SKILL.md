---
name: jj-split
description: Non-interactively split a jj revision into atomic, focused commits via CLI. Triggers on "split revision", "split commit", "jj split", "разделить коммит", "split changes", "make commits atomic", "refactor commits into smaller ones".
---

# Jujutsu Non-Interactive Split

Splits a revision into multiple atomic, focused commits using **pure CLI** — no interactive editor, no TUI, no hanging in agent environments.

## When to Use

- Current revision (`@`) contains changes to multiple unrelated files or features
- User asks to "split", "divide", or "break apart" a commit/revision
- User wants smaller, atomic commits from a large changeset
- Review finds that the current revision mixes unrelated concerns

## Core Mechanism

`jj split` supports **non-interactive mode** when you pass filesets (file paths) as positional arguments:

```bash
jj split -r <revision> -m "message for first commit" <file1> <file2> "dir/*.ts"
```

No `-i` flag = no interactive editor. Files matching the fileset go into the **selected** commit; all other changes go into the **remaining** commit.

## Step-by-Step Split Algorithm

### Step 1: Inspect current revision

```bash
# Get the revision description
jj log --no-graph -r <revision> --template 'change_id.short() ++ " | " ++ description ++ "\n"'

# Get the diff stat to see all changed files
jj diff --stat -r <revision>

# Get the full diff for analysis
jj diff -r <revision>
```

### Step 2: Identify logical groups

Analyze the diff and group changed files by **logical concern**:
- Separate feature additions from bug fixes
- Separate UI changes from backend changes
- Separate config changes from code changes
- Separate test changes from implementation changes
- Group by module/feature area (e.g., `src/auth/*`, `src/payments/*`)

**Goal**: Each group should answer "what single logical change does this represent?"

### Step 3: Split the first group (stays in original commit)

The **first** group of files stays in the original commit. Remaining files are pushed into a new child commit:

```bash
jj split -r <revision> -m "Description of FIRST logical group" <file1> <file2> "glob_pattern"
```

Result:
```
Before:  J — K (all changes)
After:   J — K' (first group) — K" (remaining)
```

### Step 4: Split remaining groups

After the first split, **remaining changes are now in the child commit** (`K"`). Get its change ID:

```bash
jj log --no-graph -r '@-' --template 'change_id.short()'
```

Then split the child commit. Repeat for each logical group. The **last** group naturally becomes the final commit — no split needed for it:

```bash
# Split second group from the child
jj split -r <child-change-id> -m "Description of SECOND group" <files-for-second>

# Split third group (now in the grandchild), etc.
jj split -r <grandchild-change-id> -m "Description of THIRD group" <files-for-third>

# Last group stays as-is — describe it
jj desc -r <final-change-id> -m "Description of LAST group"
```

### Step 5: Verify the result

```bash
jj log
```

Confirm each commit has a focused, atomic change with a clear description.

## Single-Commit-to-Multiple Commits Pattern

For splitting the working copy (`@`) into N atomic commits:

```bash
# 1. Inspect
jj diff --stat

# 2. First split — selected files stay in @, rest go to child
jj split -m "feat: add user model and schema" src/models/user.ts src/schema/user.sql

# 3. Check where remaining changes landed
jj log --no-graph -r '@-' --template 'change_id.short()'
# → gives you the child commit's change ID (e.g. "xyzabc")

# 4. Second split — from the child
jj split -r xyzabc -m "feat: add user API endpoints" src/api/users.ts src/routes/users.ts

# 5. Third split (if needed) — from the new child
jj log --no-graph -r '@-' --template 'change_id.short()'
jj split -r <new-child-id> -m "feat: add user validation" src/validators/user.ts src/utils/validate.ts

# 6. Describe the last remaining commit
jj desc -r <last-id> -m "docs: add user API documentation"

# 7. Final check
jj log
```

## Using `--onto` for Extract-Then-Stack Pattern

When you want to **extract** selected changes into a NEW commit (instead of keeping them in the original), use `--onto`:

```bash
# Extract specific files into a new commit on top of the parent
jj split -r <revision> --onto <revision>- -m "Extracted: specific change" <files>
```

Result:
```
Before:  J — K (all changes)
After:   J — K' (remaining)
            \
             K" (extracted, sibling of K')
```

Use this when the original commit should be preserved and you want to stack extracted changes on top.

## Using `--insert-before` / `--insert-after`

When you need to insert a split commit at a specific position in the stack:

```bash
# Insert selected changes BEFORE a specific commit
jj split -r <revision> -B <target-id> -m "Inserted before target" <files>

# Insert selected changes AFTER a specific commit
jj split -r <revision> -A <target-id> -m "Inserted after target" <files>
```

## Fileset Syntax

jj split accepts jj fileset expressions (not just plain paths):

```bash
# Specific files
jj split -m "message" src/auth/login.ts src/auth/logout.ts

# Glob patterns (quote to prevent shell expansion)
jj split -m "message" "src/auth/*.ts"

# All files in a directory
jj split -m "message" "src/utils/**"

# Negation (all except)
jj split -m "message" "all() ~ 'src/tests/**'"

# Modified files matching pattern
jj split -m "message" "modified() & 'src/api/**'"
```

## Anti-Patterns

- **NEVER use `jj split -i`** in agent environments — it opens interactive TUI and hangs
- **NEVER use `jj split` without filesets or `-m`** — it defaults to interactive mode
- **Don't split by file alone** if a single file contains changes to multiple features — that needs `-i` (interactive) which isn't agent-safe. In that case, use `jj restore` to extract specific changes, then commit manually
- **Always describe every resulting commit** — no commit should be left without a meaningful message
- **Verify with `jj log`** after the split — confirm the tree structure is what you expected

## Recovery

If a split goes wrong:

```bash
jj undo
```

This reverts to the state before the split. Then retry with corrected filesets.

## Quick Reference

| Action | Command |
|--------|---------|
| Inspect changes | `jj diff --stat -r <rev>` |
| Non-interactive split | `jj split -r <rev> -m "message" <files>` |
| Split with extract | `jj split -r <rev> --onto <rev>- -m "msg" <files>` |
| Split before target | `jj split -r <rev> -B <target> -m "msg" <files>` |
| Split after target | `jj split -r <rev> -A <target> -m "msg" <files>` |
| Get child change ID | `jj log --no-graph -r '@-' --template 'change_id.short()'` |
| Verify result | `jj log` |
| Undo split | `jj undo` |
