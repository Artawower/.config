---
name: refactor
description: Refactor existing code to improve quality, readability, architecture, consistency, simplicity, and idiomatic style — without changing observable behavior. Use this skill whenever the user says "refactor", "clean up this code", "this is messy", "too complex", "hard to read", "too much duplication", "improve code quality", or shares code with obvious structural problems. Also trigger proactively when you notice significant code smells while working on another task. Default mode is execution (make the changes); switch to plan-only if the user explicitly asks for a refactoring plan without executing changes.
---

# Refactor

Improve existing code without changing its observable behavior.

Before starting, load the canonical policy:

- `references/refactor-policy.md`

It contains the quality priorities, code smells catalog, techniques table, and hard rules. Treat it as the source of truth.

## Scope

Unless the user specifies otherwise:
- Work on the file or code the user explicitly points to.
- If a symbol (function, class, module) is named — scope to that symbol and its direct dependencies.
- Do not expand scope to the whole codebase without explicit instruction.

## Pre-condition: tests

Refactoring without tests is dangerous. Before touching any code:

1. Check if tests exist for the code to be refactored.
2. **If tests exist** — run them.
   - Green → this is your baseline, proceed.
   - Red → **stop**. Tell the user: tests are already failing before any changes. Ask whether to fix them first or proceed knowing the baseline is broken.
3. **If no tests exist** — ask the user:
   > "There are no tests covering this code. Should I write characterization tests first (recommended), or proceed without them?"
   - If characterization tests: write them, confirm green, then proceed.
   - If user declines: proceed but note the risk explicitly.

## Workflow

### Default: execute

1. Read the code — understand what it does before changing anything.
2. Satisfy the pre-condition above.
3. Identify smells using the catalog in `references/refactor-policy.md` — list what is wrong and why, ordered by impact.
4. Plan the sequence — order changes so each step is safe and independently verifiable. Low-risk techniques first.
5. Execute one change at a time:
   - Apply one named technique from the policy.
   - Run tests. Green → continue. Red → revert, find a smaller step.
   - Check diagnostics after each change.
6. Verify — run the full test suite. Confirm behavior is unchanged.
7. Report each change in this format:
   `[Technique] file:symbol — reason`

### Plan-only mode

Use only when the user explicitly asks for a refactoring plan without making changes (e.g. "show me what to refactor", "give me a plan").

Do not use this mode for code review — that is a separate skill.

Output:
- Smells found, with file and rough location
- Why each is a problem
- Technique to apply (from policy)
- Suggested order, low-risk first

## Constraints

- Do not implement fixes for bugs found during refactoring — note them, fix separately.
- Do not review code quality in isolation — use the `code-review` skill for that.
- Respond in the user's language.
