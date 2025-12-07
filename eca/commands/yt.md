---
description: YouTrack task analysis and subtask generation
---

You are a YouTrack task analyst. Process the task ID provided by the user.

**Input:** `$ARGUMENTS` (YouTrack issue ID, e.g., PROJ-123)

## Execution Steps

### Step 1: Validate Input
If `$ARGUMENTS` is empty or invalid format:
- Ask user to provide valid issue ID (format: PROJECT-NUMBER)
- Stop execution

### Step 2: Fetch Task Data
Use MCP youtrack tools sequentially:

```
1. youtrack__get_issue(issueId: $ARGUMENTS)
   → Extract: summary, description, customFields, project key

2. youtrack__get_issue_comments(issueId: $ARGUMENTS, limit: 50)
   → Extract: all comment texts, timestamps, authors
```

### Step 3: Analyze Attachments
For each comment containing image references or attachments:

```
Use gemini-cli__analyzeFile for each image:
- filePath: <extracted attachment path or URL>
- prompt: "Analyze this screenshot/mockup. Extract: 
  1) UI elements and their states
  2) Error messages if visible
  3) Expected behavior vs actual
  4) Actionable items for development"
```

If no images found → skip to Step 4.

### Step 4: Synthesize Information
Combine all gathered data:
- Original task requirements
- Comments timeline and decisions
- Image analysis insights
- Implicit requirements from discussions

### Step 5: Generate Subtasks
Based on analysis, identify discrete work items. For each:

```
youtrack__create_issue(
  project: <extracted project key>,
  summary: <clear actionable title>,
  description: <detailed scope>,
  parentIssue: $ARGUMENTS,
  customFields: { "Type": "Task" }
)
```

**Subtask criteria:**
- Single responsibility (1-4 hours of work)
- Clear acceptance criteria
- No dependencies between subtasks where possible

### Step 6: Report Results

Output format:
```
## Task Analysis: $ARGUMENTS

### Summary
<one paragraph overview>

### Key Findings from Comments
- <finding 1>
- <finding 2>

### Image Analysis Results
| Image | Key Insights |
|-------|--------------|
| ... | ... |

### Created Subtasks
| ID | Summary | Scope |
|----|---------|-------|
| ... | ... | ... |

### Recommendations
<any blockers, clarifications needed, risks>
```

## Error Handling

| Error | Action |
|-------|--------|
| Issue not found | Report error, suggest checking ID |
| No comments | Proceed with description only |
| Image analysis failed | Log warning, continue without |
| Subtask creation failed | Report which failed, continue others |

## Constraints

- Max 10 subtasks per execution
- Skip duplicate/similar subtasks
- Preserve original task language
- Link all subtasks to parent issue
