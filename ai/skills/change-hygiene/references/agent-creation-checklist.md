# Agent and Skill Creation Checklist

Use this checklist before creating or modifying an agent or skill.

## Context First

- Read neighboring files in the same area before creating a new file.
- Read the current revision description first.
- Read the last **2-3 recent commits/revisions** before creating or substantially changing an agent/skill.
- Check whether an existing agent/skill already covers the use case.

## Scope Discipline

- Keep **one role = one concern**.
- Do not mix unrelated cleanup, refactors, and new behavior in one revision.
- If the task is semantically different from the current revision, create a new revision first:

```bash
jj new -m "<description>"
```

- If you are unsure whether the scope matches, prefer a new revision.

## Tool Hygiene

- Give the minimum tool access needed for the role.
- Prefer read-only tools for research/review roles.
- Use dispatcher-only tools for coordinator roles when direct codebase access should be forbidden.
- Do not grant broad tools "just in case".

## Truthfulness Rules

- Do not promise runtime behavior that is not actually supported.
- Do not claim generic parallel dispatch unless the runtime/tooling explicitly supports it.
- Do not claim direct codebase inspection for dispatcher-only roles.
- State limitations explicitly instead of hiding them.

## Design Quality

- Keep the role narrow and specific.
- Make the trigger conditions explicit.
- State what the agent/skill must do and must not do.
- Prefer simple, predictable routing and escalation rules.
- Reuse existing patterns before inventing new abstractions.

## Coordination Changes

When the change affects orchestration, update related files only when needed:
- teams
- chains
- orchestration docs
- neighboring agent references

Do not update all of them automatically if the change does not require it.

## Documentation Hygiene

- Add docs when the new behavior changes how users or maintainers should work.
- Keep examples realistic and repository-specific when possible.
- Prefer a small main file with references over one giant prompt.

## Final Check

Before finishing, confirm:
- this belongs in the current revision
- the description is clear
- the new/changed agent has a single responsibility
- the tool list is minimal
- runtime claims are truthful
- related docs/teams/chains were updated only where necessary
