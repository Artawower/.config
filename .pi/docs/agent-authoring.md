# Agent Authoring Guide

## Purpose

This document defines practical conventions for writing agent definitions used by the current Pi orchestration setup.
Keep prompts specific, narrow, and honest about runtime capabilities.

## Agent Definition Format

Each agent is a Markdown file with YAML frontmatter and a system-prompt body.

Required frontmatter:
- `name`
- `description`
- `tools`

Example:

```md
---
name: planner
description: Implementation planning specialist
tools: read,grep,find,ls
---
You are a planning specialist...
```

## Responsibility Boundaries

Each agent should own one clear concern.

Recommended concerns in this repo:
- `coordinator` — task decomposition, routing, synthesis
- `research-coordinator` — read-heavy synthesis and investigation routing
- `arbiter` — conflict resolution and next-step decisions
- `scout` — quick recon and structure discovery
- `planner` — implementation planning
- `builder` — implementation work
- `reviewer` — code review and quality checks
- `plan-reviewer` — planning critique
- `red-team` — security and adversarial analysis
- `documenter` — documentation work

Avoid mixing multiple specialties into one agent unless the runtime truly requires it.

## Coordinator-Specific Rules

A dispatcher-only coordinator should:
- use `dispatch_agent`
- avoid direct codebase claims when it lacks codebase tools
- decompose tasks into one clear dispatch at a time
- assume sequential orchestration by default
- only use parallelism when a real supported tool/runtime path exists
- route conflicts to reviewer/critic agents instead of guessing

## Writing Good Prompts

Prompt bodies should state:
- what the agent is for
- what the agent must not do
- how to choose actions
- when to escalate
- how to report limitations

Prefer explicit rules over vague intent.

Good:
- "Use sequential delegation unless an explicit concurrent path exists"
- "Do not claim direct codebase inspection"
- "Escalate planning disagreements to plan-reviewer"

Weak:
- "Coordinate agents intelligently"
- "Use parallelism when helpful"
- "Figure out the best approach"

## Tool Selection

Use the smallest toolset that matches the role.

Typical patterns:
- read-only specialist: `read,grep,find,ls`
- implementation specialist: `read,write,edit,bash,grep,find,ls`
- dispatcher-only coordinator: `dispatch_agent`

Do not give broad codebase tools to a coordinator if the runtime model is meant to enforce delegation.

## Team Design

Use `teams.yaml` to define which agents can work together.

Guidelines:
- create a default coordinator-friendly team
- keep research-heavy teams separate from implementation-heavy teams when useful
- preserve legacy teams if other workflows still depend on them
- document when a team references external/package-provided agents

## Chain Design

Use `agent-chain.yaml` for standard sequential workflows.

Guidelines:
- name chains by outcome, not internal cleverness
- keep steps explicit
- do not imply unsupported concurrency
- use critic/reviewer passes where quality matters

## What Belongs in `AGENTS.md`

Put only repo-wide rules there:
- environment/runtime constraints
- VCS policy
- safety expectations
- orchestration truthfulness
- sequential-by-default and limited-parallel rules

Do not duplicate full agent prompts in `AGENTS.md`.

## What Belongs in Agent Files

Put role-local behavior there:
- identity and scope
- decision rules
- escalation rules
- reporting style
- role-specific constraints

## Practical Checklist

Before adding a new agent, verify:
1. Is the role meaningfully distinct from existing agents?
2. Does the tool list match the intended boundary?
3. Does the prompt state what the agent must not do?
4. Does it avoid promising unsupported runtime behavior?
5. Is it assigned to the right team(s)?
6. Does it fit an existing chain or require a new one?
