# Pi Prompt Templates

These prompt templates are now **thin wrappers** around global agent skills.

## Architecture

- `agent/prompts/` — convenient `/command` entry points for the editor autocomplete
- `agent/skills/` — source of truth for reusable AI workflows
- `agent/*.md` — role prompts for specialized agents

That means:
- humans can still type `/code-review`, `/deep-plan`, `/yt`, etc.
- the real execution logic lives in `agent/skills/`
- skills may also be called directly through `/skill:name` when skill commands are enabled

## Available Wrappers

| Wrapper | Skill | Purpose |
|---------|-------|---------|
| `/code-review` | `code-review` | Strict review of current diff |
| `/consensus-review` | `consensus-review` | Multi-model diff review with synthesis |
| `/deep-plan` | `deep-plan` | Deep planning with variants and critique |
| `/deep-test` | `deep-test` | Rigorous test strategy generation |
| `/yt` | `youtrack-task` | Analyze one YouTrack issue |
| `/yt-search` | `youtrack-search` | Search YouTrack and build a report |
| `/colleague-comments` | - | Lightweight one-shot prompt |

## Typical Usage

```bash
/code-review
/consensus-review
/deep-plan "Add OAuth login"
/deep-test "Auth middleware"
/yt PROJ-123
/yt-search "bugs assigned to me"
```

If direct skill commands are enabled, these are equivalent in intent:

```bash
/skill:code-review
/skill:consensus-review
/skill:deep-plan Add OAuth login
/skill:deep-test Auth middleware
/skill:youtrack-task PROJ-123
/skill:youtrack-search "bugs assigned to me"
```

## File Layout

```text
.pi/
└── agent/
    ├── prompts/
    │   ├── code-review.md
    │   ├── colleague-comments.md
    │   ├── consensus-review.md
    │   ├── deep-plan.md
    │   ├── deep-test.md
    │   ├── yt.md
    │   └── yt-search.md
    ├── skills/
    │   ├── code-review/SKILL.md
    │   ├── consensus-review/SKILL.md
    │   ├── deep-plan/SKILL.md
    │   ├── deep-test/SKILL.md
    │   ├── youtrack-task/SKILL.md
    │   └── youtrack-search/SKILL.md
    ├── code-reviewer.md
    ├── codebase-analyzer.md
    ├── architecture-planner.md
    └── edge-case-tester.md
```

## Notes

- `colleague-comments` intentionally stays a plain prompt template because it is lightweight and does not need orchestration.
- `code-review`, `consensus-review`, `deep-plan`, `deep-test`, `yt`, and `yt-search` are thin wrappers over skills.
- Keep long-lived workflow logic in `agent/skills/`, not in prompt files.

## Validation

Run the config smoke test after changing agents, prompt wrappers, or package-provided tools:

```bash
python3 agent/scripts/validate-config.py
```

It checks:
- declared agent tools are available from built-ins or configured packages
- `project-manager.md` references only defined agent names
- prompt wrappers do not reference missing local markdown files

## Related Docs

- Pi prompt templates: `/Users/darkawower/.volta/tools/image/packages/@mariozechner/pi-coding-agent/lib/node_modules/@mariozechner/pi-coding-agent/docs/prompt-templates.md`
- Pi skills: `/Users/darkawower/.volta/tools/image/packages/@mariozechner/pi-coding-agent/lib/node_modules/@mariozechner/pi-coding-agent/docs/skills.md`
