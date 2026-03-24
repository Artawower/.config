---
name: deep-plan
description: Produces a deep implementation plan with clarifications, multiple solution variants, and adversarial critique. Use when the user asks for architecture, a serious implementation plan, design options, or a high-confidence roadmap before coding.
---

# Deep Plan

Use this skill for non-trivial planning.

## Canonical Planning Inputs

Before planning, load the relevant role prompts:

- `references/codebase-analyzer.md`
- `references/architecture-planner.md`

Use them as the baseline for codebase mapping and implementation-plan quality.

## When to Ask Questions First

Ask clarifying questions before planning if any of these are unclear:
- success criteria
- scope boundaries
- target users or systems
- performance or security constraints
- backward-compatibility expectations
- whether the task is conceptual or tied to a specific repository

If the task is already well-scoped, proceed without blocking the user unnecessarily.

## Workflow

1. Restate the request in a clearer, stricter form.
2. Identify ambiguities, assumptions, and hidden constraints.
3. If this is repository-specific, analyze the codebase first using the standards from `references/codebase-analyzer.md`.
4. Build a concrete implementation plan using the standards from `references/architecture-planner.md`.
5. Generate at least 3 viable solution variants.
6. Keep the variants genuinely different in tradeoffs, not just reworded copies.
7. Critique each variant adversarially:
   - logical gaps
   - hidden assumptions
   - maintainability risks
   - security and reliability concerns
   - ethical or product risks when relevant
8. If a stronger external reasoning model or review tool is available, use it for an additional critique pass; otherwise do the critique yourself explicitly.
9. Produce a final recommendation with rationale and a comparative rating.

## Output Structure

Return a structured report with:
- improved task statement
- clarifying questions or explicit assumptions
- constraints and acceptance criteria
- codebase context if applicable
- step-by-step implementation plan
- variant A / B / C
- critique per variant
- final recommendation
- residual risks and open questions

## Constraints

- Do not implement code.
- Prefer executable plans over abstract essays.
- State uncertainty explicitly.
- Respond in the user's language.
