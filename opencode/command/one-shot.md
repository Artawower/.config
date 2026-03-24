---
description: Full automated pipeline — research → architecture → critique → revision → code → review → fix
---

You are executing a full development pipeline. This is NON-NEGOTIABLE: follow every phase in exact order. Do not skip, merge, or reorder phases.

**Task**: $ARGUMENTS

---

## STEP 0 — Register todos immediately

```
TodoWrite([
  { id: "p1", content: "Phase 1: Research — explore codebase + librarian (parallel)", status: "pending", priority: "high" },
  { id: "p2", content: "Phase 2: Architecture — architect agent designs the plan", status: "pending", priority: "high" },
  { id: "p3", content: "Phase 3: Critique — critic agent reviews the plan", status: "pending", priority: "high" },
  { id: "p4", content: "Phase 4: Revision — architect revises based on critique", status: "pending", priority: "high" },
  { id: "p5", content: "Phase 5: Implementation — deep agent executes the plan", status: "pending", priority: "high" },
  { id: "p6", content: "Phase 6: Code review — code-reviewer agent audits the diff", status: "pending", priority: "high" },
  { id: "p7", content: "Phase 7: Fixes — deep agent applies all review findings", status: "pending", priority: "high" }
])
```

Mark each todo `in_progress` before starting it, `completed` when done.

---

## PHASE 1 — Research

**Mark p1 in_progress.**

Fire both agents simultaneously in background:

```
call_omo_agent(
  subagent_type="explore",
  run_in_background=true,
  description="Explore codebase context",
  prompt="Explore the codebase and gather everything relevant to this task: $ARGUMENTS

  Report:
  - Project structure and tech stack
  - Related files with line ranges
  - Existing patterns and conventions to follow
  - Dependencies and contracts involved
  - Potential risks and fragile areas
  - Where to start"
)

call_omo_agent(
  subagent_type="librarian",
  run_in_background=true,
  description="Research external docs",
  prompt="Research external documentation, libraries, and best practices for: $ARGUMENTS

  Report:
  - Relevant library APIs with examples
  - Recommended patterns
  - Common pitfalls to avoid"
)
```

Collect both results. Merge into a single research summary.

**Mark p1 completed.**

---

## PHASE 2 — Architecture

**Mark p2 in_progress.**

```
task(
  subagent_type="architect",
  run_in_background=false,
  load_skills=[],
  description="Design architecture",
  prompt="Design the software architecture for: $ARGUMENTS

  ## Codebase Research
  {explore_output}

  ## External Research
  {librarian_output}

  Produce a complete architecture plan with:
  - Module/file map
  - Numbered tasks with explicit dependencies
  - Interfaces and key types
  - Acceptance criteria per task
  - Risks and out-of-scope boundaries"
)
```

Save the full architect output as `ARCH_PLAN`.

**Mark p2 completed.**

---

## PHASE 3 — Critique

**Mark p3 in_progress.**

```
task(
  subagent_type="critic",
  run_in_background=false,
  load_skills=[],
  description="Critique the architecture",
  prompt="Critically evaluate this architecture plan.

  ## Architecture Plan
  {ARCH_PLAN}

  Find: over-engineering, coupling issues, missing pieces, unclear acceptance criteria,
  undeclared dependencies, security gaps, performance traps.
  Produce a verdict: READY or NEEDS REVISION."
)
```

Save critic output as `CRITIQUE`.

**Mark p3 completed.**

---

## PHASE 4 — Revision

**Mark p4 in_progress.**

```
task(
  subagent_type="architect",
  run_in_background=false,
  load_skills=[],
  description="Revise architecture based on critique",
  prompt="Revise the architecture plan based on the critique below.

  For each issue raised:
  - ACCEPT: incorporate the change
  - REJECT: explain why with rationale
  - COMPROMISE: describe the middle ground

  Produce the FINAL implementation plan.

  ## Original Architecture Plan
  {ARCH_PLAN}

  ## Critique
  {CRITIQUE}"
)
```

Save as `FINAL_PLAN`.

**Mark p4 completed.**

---

## PHASE 5 — Implementation

**Mark p5 in_progress.**

```
task(
  category="deep",
  run_in_background=false,
  load_skills=[],
  description="Implement the plan",
  prompt="Implement the following plan step by step.

  Rules:
  - Follow the plan exactly — do not add features or change scope
  - Follow existing codebase patterns
  - After each task, check diagnostics — stop if errors found
  - Never write comments in code

  ## Final Implementation Plan
  {FINAL_PLAN}

  ## Codebase Context
  {explore_output}"
)
```

Save implementation summary as `IMPL_SUMMARY` (files changed, steps completed, issues found).

**Mark p5 completed.**

---

## PHASE 6 — Code Review

**Mark p6 in_progress.**

```
task(
  subagent_type="code-reviewer",
  run_in_background=false,
  load_skills=[],
  description="Review the implementation",
  prompt="Review the implementation against the plan and code quality standards.

  Run: git diff HEAD to see all changes.
  Check each changed file against the rules.

  ## Implementation Plan (for plan compliance check)
  {FINAL_PLAN}

  ## What was implemented
  {IMPL_SUMMARY}"
)
```

Save review output as `REVIEW`.

**Mark p6 completed.**

---

## PHASE 7 — Fixes

**Mark p7 in_progress.**

```
task(
  category="deep",
  run_in_background=false,
  load_skills=[],
  description="Apply review fixes",
  prompt="Apply all fixes from the code review.

  Rules:
  - Fix every Critical and Major issue
  - For each fix, explicitly state what was changed and why
  - Do not change anything outside the review scope
  - If you disagree with a finding, state the objection — do not silently ignore it

  ## Code Review Findings
  {REVIEW}

  ## Original Plan (for context)
  {FINAL_PLAN}"
)
```

**Mark p7 completed.**

---

## Completion report

After all phases, present:

```
## Pipeline Complete

### Phases executed
- [x] Phase 1: Research
- [x] Phase 2: Architecture
- [x] Phase 3: Critique
- [x] Phase 4: Revision
- [x] Phase 5: Implementation
- [x] Phase 6: Code Review
- [x] Phase 7: Fixes

### Files changed
{list of files}

### Open issues
{anything that could not be resolved automatically}

### Objections from coder (if any)
{any disagreements with review findings}
```
