---
description: Full automated pipeline — research → architecture → critique → revision → code → review → fix
---

You are executing a full development pipeline. Follow every phase in exact order. Do not skip, merge, or reorder phases.

**Task**: $ARGUMENTS

---

## STEP 0 — Register todos

```
eca__task(op="plan", tasks=[
  { subject: "Phase 1: Research", description: "Spawn explorer + researcher in parallel, merge results" },
  { subject: "Phase 2: Architecture", description: "Spawn architect with research output, save ARCH_PLAN" },
  { subject: "Phase 3: Critique", description: "Spawn critic with ARCH_PLAN, save CRITIQUE" },
  { subject: "Phase 4: Revision", description: "Spawn architect with ARCH_PLAN + CRITIQUE, save FINAL_PLAN" },
  { subject: "Phase 5: Implementation", description: "Spawn executor with FINAL_PLAN" },
  { subject: "Phase 6: Code review", description: "Spawn critic (code-reviewer) with FINAL_PLAN + impl summary" },
  { subject: "Phase 7: Fixes", description: "Spawn executor with review findings" }
])
```

Mark each task `in_progress` before starting, `complete` when done.

---

## PHASE 1 — Research

**Mark Phase 1 in_progress.**

Spawn both subagents simultaneously (parallel tool calls):

```
eca__spawn_agent(
  agent="explorer",
  task="Explore the codebase and gather everything relevant to this task: $ARGUMENTS

  Report:
  - Project structure and tech stack
  - Related files with line ranges
  - Existing patterns and conventions to follow
  - Dependencies and contracts involved
  - Potential risks and fragile areas
  - Where to start"
)

eca__spawn_agent(
  agent="researcher",
  task="Research external documentation, libraries, and best practices for: $ARGUMENTS

  Report:
  - Relevant library APIs with examples
  - Recommended patterns
  - Common pitfalls to avoid"
)
```

Collect both results. Merge into a single research summary. Save as RESEARCH.

**Mark Phase 1 complete.**

---

## PHASE 2 — Architecture

**Mark Phase 2 in_progress.**

```
eca__spawn_agent(
  agent="architect",
  task="Design the software architecture for: $ARGUMENTS

  ## Codebase Research
  {RESEARCH — explorer output}

  ## External Research
  {RESEARCH — researcher output}

  Produce a complete architecture plan."
)
```

Save full output as ARCH_PLAN.

**Mark Phase 2 complete.**

---

## PHASE 3 — Critique

**Mark Phase 3 in_progress.**

```
eca__spawn_agent(
  agent="critic",
  task="Critically evaluate this architecture plan.

  ## Architecture Plan
  {ARCH_PLAN}

  Find: over-engineering, coupling issues, missing pieces, unclear acceptance criteria,
  undeclared dependencies, security gaps, performance traps.
  Verdict: READY or NEEDS REVISION."
)
```

Save output as CRITIQUE.

**Mark Phase 3 complete.**

---

## PHASE 4 — Revision

**Mark Phase 4 in_progress.**

If CRITIQUE verdict is READY — skip to Phase 5, use ARCH_PLAN as FINAL_PLAN.

If NEEDS REVISION:

```
eca__spawn_agent(
  agent="architect",
  task="Revise the architecture plan based on the critique.

  For each issue raised respond with ACCEPT / REJECT (with rationale) / COMPROMISE.
  Produce the FINAL implementation plan.

  ## Original Architecture Plan
  {ARCH_PLAN}

  ## Critique
  {CRITIQUE}"
)
```

Save as FINAL_PLAN.

**Mark Phase 4 complete.**

---

## PHASE 5 — Implementation

**Mark Phase 5 in_progress.**

```
eca__spawn_agent(
  agent="executor",
  task="Implement the following plan step by step.

  Rules:
  - Follow the plan exactly — do not add features or change scope
  - Follow existing codebase patterns
  - After each step check diagnostics — stop if errors found
  - Never write comments in code

  ## Final Implementation Plan
  {FINAL_PLAN}

  ## Codebase Context
  {RESEARCH — explorer output}"
)
```

Save execution summary as IMPL_SUMMARY (files changed, steps completed, issues found).

**Mark Phase 5 complete.**

---

## PHASE 6 — Code Review

**Mark Phase 6 in_progress.**

```
eca__spawn_agent(
  agent="critic",
  task="Review the implementation against the plan and code quality standards.

  Run git diff HEAD to see all changes.
  Check each changed file against the rules.

  ## Implementation Plan
  {FINAL_PLAN}

  ## What was implemented
  {IMPL_SUMMARY}"
)
```

Save review output as REVIEW.

**Mark Phase 6 complete.**

---

## PHASE 7 — Fixes

**Mark Phase 7 in_progress.**

If REVIEW verdict is APPROVED — skip.

```
eca__spawn_agent(
  agent="executor",
  task="Apply all fixes from the code review.

  Rules:
  - Fix every Critical and Major issue
  - For each fix explicitly state what was changed and why
  - Do not change anything outside the review scope
  - If you disagree with a finding, state the objection — do not silently ignore it

  ## Code Review Findings
  {REVIEW}

  ## Original Plan
  {FINAL_PLAN}"
)
```

**Mark Phase 7 complete.**

---

## Completion report

Present:

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
{list}

### Open issues
{anything unresolved}

### Objections from executor
{any disagreements with review findings}
```
