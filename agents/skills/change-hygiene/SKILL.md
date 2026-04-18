---
name: change-hygiene
description: Helps describe changes clearly, follow conventional commit style, keep jj revisions focused, and apply agent/skill creation best practices. Use whenever the user asks how to name a change, write a commit or revision description, decide whether to reuse the current jj revision, create or modify an agent or skill, or wants cleaner change hygiene before editing files.
---

# Change Hygiene

Use this skill whenever the work involves:
- naming a change
- writing or refining a revision description
- deciding whether the current task belongs in the current jj revision
- creating or updating an agent
- creating or updating a skill
- cleaning up change scope before editing files

This skill is about **scope discipline**, **clear change descriptions**, and **safe agent/skill evolution**.

## Before Changing Anything

Follow this order unless the user explicitly asks for theory-only advice:

1. Read the current revision description.
2. Read the last **2-3 recent commits/revisions** for context.
3. Compare the requested task to the current revision's semantic scope.
4. If the task is outside the current scope, create a new revision before editing files.
5. If the task is within scope, continue in the current revision.

### Required jj workflow

Check the current revision first:

```bash
jj log --no-graph -r @ --template 'change_id.short() ++ " | " ++ if(description, description, "(empty)")'
```

Then inspect recent history for context. Read **2-3 recent revisions** before creating or substantially modifying an agent/skill or other structured workflow artifact:

```bash
jj log -r '::@' --limit 3
```

If you need patch-level context, prefer a more detailed history view:

```bash
jj log -p -r '::@' --limit 3
```

## Scope Decision Rule

### Same semantic scope
Stay in the current revision when the new task is part of the same logical change.
Examples:
- polishing the prompt of the agent you are already adding
- fixing a typo in docs for the same feature
- updating a team entry that is required for the same new skill/agent

### Different semantic scope
Create a new revision before touching files when the task is a different feature, unrelated cleanup, or a separate refactor.

Use:

```bash
jj new -m "<description>"
```

If you are unsure whether the scope matches, prefer creating a new revision.

## Revision Description Rules

A good jj revision description should be:
- short
- specific
- imperative
- focused on one logical change
- understandable without reading the diff first

Good descriptions:
- `feat(agents): add coordinator orchestration policy`
- `docs(skills): add change hygiene skill`
- `fix(pi): correct agent team loading notes`
- `refactor(agents): simplify coordinator team layout`

Bad descriptions:
- `stuff`
- `updates`
- `misc fixes`
- `agent changes and docs and cleanup`

Read `references/conventional-commits.md` for the recommended message format.

## Agent and Skill Creation Hygiene

Before creating or changing an agent/skill:

1. Read neighboring files in the same area.
2. Read the last **2-3 relevant commits/revisions**.
3. Check whether an existing agent/skill already covers the use case.
4. Keep one role = one concern.
5. Give the smallest toolset that matches the role.
6. Do not promise runtime capabilities that do not exist.
7. Update teams, chains, or docs only when the change actually requires it.
8. Do not mix unrelated cleanup into the same revision.

Read:
- `references/agent-creation-checklist.md`
- `references/examples.md`

## Truthfulness Rules

- Do not claim direct codebase inspection if the role is dispatcher-only.
- Do not claim generic parallel dispatch if the runtime only supports sequential delegation.
- Do not pretend recent history was reviewed if it was unavailable; say so explicitly.
- Do not invent a new agent when refining an existing one would solve the problem more simply.

## Conventional Commit Guidance

Use conventional commit style as the default recommendation for revision descriptions unless the repository has a stronger local convention.

Preferred types:
- `feat`
- `fix`
- `docs`
- `refactor`
- `chore`
- `test`
- `build`
- `ci`
- `perf`

Scopes are optional but helpful when they clarify the affected area.

See `references/conventional-commits.md`.

## What to Report Back

When helping a user with change hygiene, report:
- current revision description
- the 2-3 recent revisions you reviewed
- whether the task matches the current scope
- whether `jj new` is needed
- a suggested revision description
- any agent/skill hygiene cautions

## Output Template

Use this compact structure when relevant:

```markdown
## Change Hygiene Check
- Current revision: ...
- Recent revisions reviewed: ...
- Scope decision: reuse current revision / create new revision
- Suggested jj command: `jj new -m "..."` (if needed)
- Suggested revision description: ...
- Agent/skill cautions: ...
```

## Reference Files

- `references/conventional-commits.md` — recommended conventional commit types, scope guidance, and examples
- `references/agent-creation-checklist.md` — checklist for safe agent/skill changes
- `references/examples.md` — same-scope vs new-scope examples and sample revision descriptions
