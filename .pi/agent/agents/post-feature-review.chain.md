---
name: post-feature-review
description: "Post-feature quality gate: review → architect analysis → fix. Run after completing a feature/bugfix/refactor."
---

## ag-reviewer
output: review.md

Perform a strict code review on all uncommitted changes in the current jj revision.
Read changed files directly — do not rely on descriptions alone.
Apply the full KISS/DRY/SOLID rubric. Check correctness, security, performance, tests, style.
Produce review.md with: Summary, Critical Issues, Major Issues, Minor/Style, Secure & Robust, Tests to Add, Patch Sketch.

## ag-planner
reads: review.md
output: fix-plan.md

You are acting as a post-implementation architect. Your input is a code review report (review.md), NOT a research document.
Analyze the review findings:
- Triage each issue: accept (genuine problem), reject with rationale (false positive / intentional tradeoff), or defer (out of scope for this fix pass).
- Prioritize accepted issues: Critical first, then Major, then Minor only if trivial.
- For each accepted issue, specify the minimal fix: exact file, exact change, no over-engineering.
- If the review found no Critical or Major issues, state "NO FIXES NEEDED" and explain why.
Review: {previous}

## ag-coder
reads: fix-plan.md, review.md

Apply all fixes from fix-plan.md.
Address every accepted Critical and Major issue.
Skip deferred and rejected items.
Confirm each fix explicitly in a brief summary.
Fix Plan: {previous}
