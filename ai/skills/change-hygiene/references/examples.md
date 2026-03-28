# Examples

## Same Scope: Continue in Current Revision

### Scenario
Current revision description:
- `feat(agents): add coordinator orchestration policy`

Requested follow-up task:
- refine the coordinator prompt to clarify sequential-by-default behavior

### Decision
This is the same semantic scope.
Stay in the current revision.

### Good follow-up description
- keep the existing revision description if it still fits
- or refine it slightly if needed using `jj desc -m ...`

## New Scope: Create a New Revision

### Scenario
Current revision description:
- `feat(agents): add coordinator orchestration policy`

Requested follow-up task:
- add a new skill for commit hygiene and agent creation best practices

### Decision
This is a different semantic scope.
Create a new revision first.

### Command
```bash
jj new -m "docs(skills): add change hygiene skill"
```

## Agent Creation: Read Recent History First

### Scenario
You want to add a new agent for repository research.

### Required prep
1. read the current revision description
2. read the last **2-3 recent revisions**
3. read neighboring agent files
4. decide whether the work belongs in the current revision

### Good decision path
- if recent history shows you are already in a revision adding related research agents, continue
- if recent history shows the current revision is about an unrelated UI tweak or docs cleanup, create a new revision first

## Good Revision Descriptions

- `feat(agents): add research coordinator`
- `docs(skills): add change hygiene guidance`
- `fix(agents): correct reviewer routing policy`
- `refactor(teams): simplify coordinator team layout`
- `chore(config): reorder package settings`
- `test(skills): add eval prompts for change hygiene`

## Bad Revision Descriptions

- `stuff`
- `updates`
- `misc cleanup`
- `agent changes`
- `new things`

## Same-Scope vs New-Scope Heuristic

### Same scope
Use the current revision when the new task is required to complete the current logical change.

Examples:
- add a missing team entry for the agent you are already introducing
- fix wording in docs for the same feature
- refine the prompt of the same new skill

### New scope
Create a new revision when the new task is a separate feature, unrelated cleanup, or a different workflow concern.

Examples:
- current revision is about agent orchestration, new task is about shell config
- current revision is about a skill, new task is about unrelated reviewer refactoring
- current revision is about docs, new task is about adding a new runtime extension
