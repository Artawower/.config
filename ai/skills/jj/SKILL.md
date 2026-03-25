---
name: jj
description: Use Jujutsu (jj) for version control instead of git. Always check current revision before making changes — if the task semantically differs from the current revision's description, create a new revision first.
---

# Jujutsu (jj) Version Control

This project uses `jj` (Jujutsu) for version control. Always use `jj` commands — never `git commit`, `git add`, or `git branch`.

## Before making any code changes

Run:

```bash
jj log --no-graph -r @ --template 'change_id.short() ++ " | " ++ if(description, description, "(empty)")'
```

This gives you the current working-copy revision and its description.

### Decision rule

Compare the current revision description with the task you are about to implement:

- **Same semantic scope** (e.g. both about fixing the same bug, same feature): continue working in the current revision — no action needed.
- **Different semantic scope** (different feature, unrelated fix, new task): create a new revision before touching any files:

```bash
jj new -m "<short description of what you're about to do>"
```

This ensures each revision stays focused on a single logical change.

## Core workflow

### Check status
```bash
jj status
```

### Describe current revision
```bash
jj describe -m "<message>"
```

Use after completing a logical unit of work. Follow the project's commit message convention if present.

### Create new revision from current
```bash
jj new -m "<message>"
```

### View history
```bash
jj log
```

### Undo last operation
```bash
jj undo
```

## Hard rules

- Check `jj log -r @` **before** editing any file
- If the revision description is empty `(empty)` — describe it before or after your changes
- Never use `git commit` or `git add` — jj tracks changes automatically, no staging needed
- One revision = one logical change; do not mix unrelated modifications in a single revision
- If unsure whether the scope matches — create a new revision; it's cheap to squash later with `jj squash`
