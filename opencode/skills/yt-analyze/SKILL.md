---
name: yt-analyze
description: Fetch YouTrack task + comments via MCP, critically analyze relevance and requirements, produce concise summary of what to implement, and build an implementation plan mapped to codebase. Trigger - YouTrack issue ID or request to "analyze task", "plan task", "break down YT issue".
---

## What I do

Deep analysis of a YouTrack task end-to-end:
1. Fetch task description, comments, linked issues, and metadata via YouTrack MCP
2. Critically evaluate: is the task still relevant? Are requirements clear? Are there contradictions?
3. Distill a concise implementation brief from noisy discussion threads
4. Map the problem/feature to specific files and modules in the current codebase
5. Produce an actionable implementation plan with concrete steps

## When to use me

- User provides a YouTrack issue ID and wants to understand what to build
- User asks to "analyze task", "plan YT issue", "what does PROJ-123 need"
- User wants to start working on a task but needs clarity first
- User wants to evaluate if a task is still relevant before investing effort

## WORKFLOW

### STEP 1: Fetch task data

Use YouTrack MCP tools to gather all context:

```
1. youtrack_get_issue(issueId: "<ISSUE_ID>")
   → Extract: summary, description, customFields (State, Type, Priority, Assignee),
     project key, tags, votes, resolved status, created/updated dates

2. youtrack_get_issue_comments(issueId: "<ISSUE_ID>", limit: 10)
   → Extract: all comment texts, authors, timestamps
   → Note: comments are chronological — later comments may override earlier decisions

3. youtrack_get_issue(issueId: "<PARENT_OR_LINKED>") — if linked issues exist
   → Check linkedIssueCounts in the original issue
   → Fetch parent task or key linked issues for broader context
```

If the issue has image attachments in description or comments, analyze them for UI mockups, error screenshots, or diagrams.

If the issue is not found, tell the user and stop.

### STEP 2: Critical analysis

Apply structured critical thinking to all gathered data. Answer each question explicitly:

#### 2a. Relevance check

- **Is this still relevant?** Compare created date, last activity, current State.
  If no activity for 6+ months and State is still Open — flag as potentially stale.
- **Has it been superseded?** Check if comments mention "moved to", "duplicate of", "replaced by".
- **Is it already partially done?** Look for comments mentioning PRs, commits, branches, partial implementations.
- **Does the current codebase already solve this?** Search the codebase for keywords from the task description.

#### 2b. Requirements clarity

- **Are requirements specific enough to implement?** Can you write code from the description alone?
- **Are there contradictions?** Between description and comments, between different commenters, between title and body.
- **Are there hidden assumptions?** What does the task assume about the system that might not be true?
- **What's NOT specified?** Error handling, edge cases, backwards compatibility, performance, mobile/desktop.
- **What questions remain unanswered in the thread?** Flag open questions that were asked but never answered.

#### 2c. Scope assessment

- **What's the minimum viable implementation?** Strip to core value.
- **What's the full scope if done properly?** Including tests, docs, migrations.
- **Are there scope creep signals?** Comments adding "also do X", "while you're at it".
- **Estimated effort?** T-shirt size: XS (<1h), S (1-4h), M (4-16h), L (16-40h), XL (40h+).

### STEP 3: Produce implementation brief

Synthesize all data into a concise brief. This is the KEY deliverable — distill noisy threads into clarity.

Format:

```
## Task Brief: {ISSUE_ID} — {SUMMARY}

**Type**: {Bug|Feature|Improvement|Task}
**Priority**: {Critical|Major|Normal|Minor}
**Relevance**: {Current|Stale|Superseded|Partially done}
**Estimated effort**: {XS|S|M|L|XL}

### What needs to happen
{2-5 sentences. Concrete, specific. What the user/system should do differently after this is implemented.}

### Acceptance criteria
1. {Specific, testable criterion}
2. {Specific, testable criterion}
3. ...

### What's explicitly out of scope
- {Thing mentioned but not part of this task}

### Open questions (if any)
- {Question that needs answering before implementation}

### Key context from discussion
- {Important decision or clarification from comments, with author attribution}
```

### STEP 4: Map to codebase

Search the current codebase to identify exactly where changes are needed.

**Search strategy:**
1. Extract key terms from the task (feature names, UI elements, API endpoints, error messages)
2. Search codebase for these terms using grep/find/AST tools
3. For each hit, determine: is this the place to modify, or just a reference?
4. Map the dependency chain: if file A changes, what else is affected?

**What to identify:**
- **Entry points**: Which files/functions are the starting point for this change?
- **Core logic**: Where does the main business logic live?
- **UI components**: Which components need modification? (if frontend)
- **API layer**: Which endpoints/handlers are involved? (if backend)
- **Data layer**: Any schema/model/store changes needed?
- **Tests**: Which existing test files cover this area?
- **Config**: Any environment/build config changes needed?

If the project has AGENTS.md — read it first to understand architecture, conventions, and file organization.

### STEP 5: Build implementation plan

Create a step-by-step plan that a developer (or AI agent) can follow sequentially.

Format:

```
## Implementation Plan: {ISSUE_ID}

### Affected files
| File | Change type | Description |
|------|-------------|-------------|
| src/auth/login.ts | Modify | Add token refresh logic |
| src/auth/refresh.ts | Create | New refresh token handler |
| src/auth/login.spec.ts | Modify | Add refresh tests |

### Steps (in order)

#### Step 1: {Short title}
**Files**: `src/path/to/file.ts`
**What**: {Specific change description — what to add/modify/remove}
**Why**: {How this connects to the requirement}
**Watch out**: {Gotchas, edge cases, things to not break}

#### Step 2: {Short title}
...

### Verification
1. {How to verify step 1 works}
2. {How to verify step 2 works}
3. {Final integration check}

### Risks
- {What could go wrong}
- {What might break}
```

**Plan rules:**
- Each step = 1 logical unit of work (can be committed independently)
- Steps are ordered by dependency (step 2 may depend on step 1)
- Each step names specific files and functions
- Total steps: 3-10 (if more — the task is too large, suggest splitting)
- Include a verification method for each step

### STEP 6: Present to user

Show the full analysis:
1. Implementation Brief (STEP 3)
2. Codebase Mapping (STEP 4)
3. Implementation Plan (STEP 5)

If critical issues were found in STEP 2 (stale, contradictions, missing requirements):
- Show them FIRST, before the plan
- Ask: "Should I proceed with the plan despite these issues, or do you want to resolve them first?"

### STEP 7: Ask for action

```
What would you like to do?
- "start" — begin implementing step 1 of the plan
- "refine" — adjust the plan (specify what to change)
- "comment" — post the analysis as a comment on the YT task
- "subtasks" — create subtasks in YT from the plan steps
- "done" — analysis complete, no further action
```

Wait for user response. Do NOT proceed without explicit instruction.

### STEP 8: Execute action (if requested)

#### If "start":
1. Begin implementing Step 1 from the plan
2. Follow the plan sequentially
3. Mark completed steps

#### If "comment":
Post the Implementation Brief as a YouTrack comment:
```
youtrack_add_issue_comment(
  issueId: "<ISSUE_ID>",
  text: "<Implementation Brief markdown>"
)
```

#### If "subtasks":
For each plan step, create a subtask:
```
youtrack_create_issue(
  project: "<PROJECT_KEY>",
  summary: "Step N: <step title>",
  description: "<step details + affected files + verification>",
  parentIssue: "<ISSUE_ID>",
  customFields: { "Type": "Task" }
)
```

## Hard rules

- NEVER modify YouTrack tasks without explicit user permission (no auto-update of State, Assignee, etc.)
- NEVER create subtasks without explicit user permission
- NEVER start implementing without explicit user permission
- If YouTrack MCP is not configured or auth fails — tell user and stop
- Answer in the same language the user uses
- Be honest about uncertainty: if requirements are unclear, SAY SO — don't guess
- Don't invent requirements that aren't in the task or comments
- Distinguish between FACTS (from task data) and INFERENCES (your analysis) — label them
- When mapping to codebase: verify files exist before listing them in the plan
- If the codebase doesn't match the task context (wrong repo) — warn the user
