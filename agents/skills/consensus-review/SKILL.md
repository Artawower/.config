---
name: consensus-review
description: Runs an independent multi-model review of the current diff, stores per-model reports, merges duplicates, and produces a skeptical consolidated verdict in Russian. Use when one reviewer is not enough and the user wants crowd wisdom.
---

# Consensus Review

Use this skill when the user wants several independent review opinions and one consolidated report.

## Canonical Review Rubric

Before starting, load:

- `references/code-reviewer.md`

Use that rubric as the common review contract for every model.

## Default Scope

Review only uncommitted changes unless the user specifies a different range.

```bash
git diff HEAD --name-only
```

If there is no diff, report that and stop.

## Required Artifacts

Write results to:

- `plans/review/qwen-cli-review.md`
- `plans/review/codex-5.1-review.md`
- `plans/review/gemini-2.5pro-review.md`
- `plans/review/deepseek-3.2pro-review.md`
- `plans/review/overview.md`

Create `plans/review/` if needed.

## Execution Workflow

1. Identify the exact diff scope.
2. Inspect available MCP or model gateway tools instead of assuming tool names blindly.
3. Prepare one shared review brief based on `references/code-reviewer.md`.
4. Run independent reviews with these targets when available:
   - qwen cli
   - codex 5.1 high
   - gemini 2.5 pro
   - deepseek 3.2 pro
5. Save each raw review to its own artifact file.
6. Merge findings by severity and deduplicate overlapping comments.
7. For every merged point, verify relevance against the actual diff instead of trusting model output automatically.
8. Produce `plans/review/overview.md` with:
   - merged findings
   - false positives removed or marked
   - severity buckets
   - short rationale per accepted point
9. Return a final processed report in Russian.

## Fallback Rules

- If one or more models are unavailable, continue with the available ones.
- Explicitly list which reviewers were unavailable.
- Never invent tool names or pretend a model ran when it did not.

## Final Output

The final user-facing answer must include:
- which models were used
- the most important confirmed issues
- which findings were rejected as noise
- the overall verdict on the diff
- references to the generated artifact files
