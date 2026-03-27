# Prompt Templates — Quick Reference

## Commands

```bash
/code-review
/consensus-review
/colleague-comments "feedback text"
/deep-plan "task description"
/deep-test "what to test"
/yt PROJ-123
/yt-search "query"
```

## What Runs Under the Hood

| Command | Backed by | Notes |
|---------|-----------|-------|
| `/code-review` | `agent/skills/code-review` | Review current diff |
| `/consensus-review` | `agent/skills/consensus-review` | Multi-model review |
| `/deep-plan` | `agent/skills/deep-plan` | Planning + critique |
| `/deep-test` | `agent/skills/deep-test` | Test strategy + critique |
| `/yt` | `agent/skills/youtrack-task` | Analyze one YouTrack issue |
| `/yt-search` | `agent/skills/youtrack-search` | Search YouTrack |
| `/colleague-comments` | prompt only | Lightweight analysis |

## Direct Skill Commands

If skill commands are enabled:

```bash
/skill:code-review
/skill:consensus-review
/skill:deep-plan Add OAuth login
/skill:deep-test Auth middleware
/skill:youtrack-task PROJ-123
/skill:youtrack-search "bugs assigned to me"
```

## Validation

```bash
python3 agent/scripts/validate-config.py
```

## Rule of Thumb

- `agent/prompts/` = UX shortcuts
- `agent/skills/` = reusable AI workflows
- `agent/*.md` = role definitions
