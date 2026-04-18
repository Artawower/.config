---
name: youtrack-task
description: Analyzes a YouTrack issue, reviews comments and attachments, and proposes or creates actionable subtasks. Use when the user gives a YouTrack issue ID and wants synthesis, decomposition, or follow-up tasks.
---

# YouTrack Task Analysis

Use this skill for issue-centric YouTrack work.

## Input

Expected input: a YouTrack issue ID like `PROJ-123`.

If the input is missing or malformed, ask for a valid issue ID and stop.

## Workflow

1. Inspect available MCP tools for YouTrack and any configured image-analysis model.
2. Fetch the issue details.
3. Fetch comments and recent discussion.
4. Detect attachments or image references when possible.
5. If image analysis is available, analyze screenshots or mockups and extract:
   - visible UI states
   - error messages
   - expected vs actual behavior
   - concrete implementation clues
6. Synthesize:
   - explicit requirements
   - implicit requirements from comments
   - decisions already made
   - blockers, risks, and unanswered questions
7. Break the work into small subtasks when appropriate.
8. Avoid duplicate or overly broad subtasks.
9. If the user asked to create subtasks and the MCP tool allows it, create them under the parent issue.
10. Return a structured report in the original task language when possible.

## Subtask Rules

- Max 10 subtasks per run
- One concern per subtask
- Clear scope and acceptance criteria
- Prefer low coupling between subtasks
- Preserve parent-project conventions

## Output Structure

Return:
- issue summary
- key findings from comments
- image-analysis findings if any
- proposed or created subtasks
- risks / blockers / recommendations

## Safety Rules

- Do not create issues unless the user asked for creation or the task explicitly requires it.
- If write access is missing, provide proposed subtasks instead.
- Never invent unavailable attachments or missing comments.
