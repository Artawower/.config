---
name: one-shot
description: "Full pipeline: research → architecture → critique → revision → code → review → fix."
---

## ag-researcher
output: research.md

Research the project and gather context for: {task}
Include project structure, existing patterns, dependencies, and constraints.

## ag-planner
reads: research.md
output: architecture.md

Based on the research, design the software architecture.
Focus on component boundaries, data flow, interfaces, and key decisions.
Research: {previous}

## ag-critic
reads: architecture.md
output: critique-arch.md

Critically evaluate the architecture from a software design perspective.
Flag over-engineering, missing pieces, coupling issues, unclear boundaries.
Architecture: {previous}

## ag-planner
reads: architecture.md, critique-arch.md
output: final_plan.md

Revise the architecture based on the critic's feedback.
Address each point explicitly — accept, reject with rationale, or compromise.
Produce a final actionable implementation plan with clear steps.
Critique: {previous}

## ag-coder
reads: final_plan.md
output: implementation_notes.md

Implement the finalized plan step by step.
Write clean, tested, production-ready code.
Plan: {previous}

## ag-reviewer
reads: implementation_notes.md, final_plan.md
output: review.md

Perform strict code review on the implementation. Read the changed files directly.
Check against the plan's acceptance criteria. Identify bugs, style issues, missing tests, security gaps.
{previous}

## ag-coder
reads: review.md, implementation_notes.md

Fix all issues from the code review. Confirm each fix explicitly.
Review: {previous}
