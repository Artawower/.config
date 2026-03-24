---
name: AGENTS
description: A complete pipeline from research to planning, critique, coding, and review.
---

## ag-researcher
output: research.md

Research the project and web to gather context for: {task}
Include project structure and any required online information.

## ag-planner
reads: research.md
output: plan.md

Create a detailed architecture and implementation plan based on the research in:
{previous}

## ag-critic
reads: plan.md
output: critique.md

Review and critique the proposed plan. Focus on edge cases, security, and over-engineering:
{previous}

## ag-planner
reads: plan.md, critique.md
output: final_plan.md

Revise and finalize the architecture plan based on the critic's feedback:
{previous}
Output the final actionable plan.

## ag-coder
reads: final_plan.md
output: implementation_notes.md

Implement the finalized plan. Write the necessary code and tests:
{previous}

## ag-reviewer
reads: implementation_notes.md
output: review.md

Perform a strict code review on the implementation. Identify any bugs, style issues, or missing requirements:
{previous}

## ag-coder
reads: review.md, implementation_notes.md
output: final_status.md

Fix the issues raised in the code review and ensure code is production ready:
{previous}