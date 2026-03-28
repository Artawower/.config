# Agent Orchestration

## Goal

This repository supports practical multi-agent orchestration built around the current Pi runtime.
The design is intentionally honest about what the runtime can do today:
- coordinator-driven dispatch is supported
- sequential specialist handoffs are the default
- limited parallel fan-out is allowed only through explicit tooling/runtime support

## Core Model

### Coordinator
A coordinator is a dispatcher-only agent that:
- restates the task
- decomposes it into small sub-tasks
- chooses specialists from the active team
- dispatches work step by step
- synthesizes results
- routes conflicts to reviewer/critic-style agents

### Arbiter
An arbiter is a narrower decision agent used when:
- prior outputs conflict
- a dispatch failed and the next step is unclear
- a conclusion is risky and needs a disciplined accept/retry/reroute/escalate decision

### Specialists
Specialists do the actual focused work:
- `scout`
- `planner`
- `builder`
- `reviewer`
- `plan-reviewer`
- `red-team`
- `documenter`

## Runtime Reality

### Sequential by Default
The current generic coordinator model assumes:
- one dispatch targets one agent
- the coordinator waits for the result
- the next action is chosen after inspecting that result

This is the safest default for the current runtime and should be treated as the baseline orchestration contract.

### Limited Parallel Only
Parallel work is allowed only when the runtime exposes an explicit concurrent path.
Examples:
- a dedicated batch tool
- an expert-query mechanism designed for fan-out and merge

If that path is absent, coordinators must fall back to sequential dispatch.
They must not imply that generic `dispatch_agent` supports arbitrary parallelism.

## Teams

Team membership is defined in `.pi/agents/teams.yaml`.
Use teams to constrain which specialists the coordinator can call.

Recommended coordinator-oriented teams:
- `coordinator-default`
- `coordinator-research`
- `coordinator-review`
- `coordinator-lightweight`

Legacy teams are preserved for compatibility.
Some legacy `ag-*` names may come from installed packages rather than local files.

## Chains

Standard sequential workflows live in `.pi/agents/agent-chain.yaml`.
These are workflow templates, not proof of runtime concurrency.

Recommended coordinator-oriented chains:
- `coordinator-scout-plan-build-review`
- `coordinator-plan-critique-revise`
- `coordinator-review-redteam-arbitrate`
- `coordinator-research-sequential`

## Routing Policy

### Use sequential specialist handoffs when:
- the next step depends on the previous result
- implementation work is involved
- review must inspect a concrete output
- the runtime does not expose a real parallel path

### Consider limited parallel fan-out only when:
- the tool/runtime explicitly supports it
- tasks are independent
- results can be synthesized safely afterward
- the work is research-heavy rather than mutation-heavy

## Conflict Handling

If results disagree:
1. identify the disagreement clearly
2. choose the right critic/reviewer
3. validate before concluding
4. escalate to the user if the runtime or team cannot resolve the issue safely

Suggested routing:
- planning conflict -> `plan-reviewer`
- code-quality/correctness conflict -> `reviewer`
- security/abuse-risk conflict -> `red-team`
- unresolved multi-party disagreement -> `arbiter`

## What Goes Where

### `AGENTS.md`
Put repo-wide truth here:
- environment constraints
- VCS constraints
- safety rules
- orchestration truthfulness
- sequential-by-default and limited-parallel policy

### `.pi/agents/*.md`
Put role-specific behavior here:
- agent purpose
- allowed tools
- must-do / must-not-do rules
- routing or escalation behavior

### `.pi/agents/teams.yaml`
Put team composition here.

### `.pi/agents/agent-chain.yaml`
Put standard sequential workflow templates here.

## Examples

### Standard coding flow
1. coordinator dispatches `scout`
2. coordinator dispatches `planner`
3. coordinator dispatches `builder`
4. coordinator dispatches `reviewer`
5. coordinator summarizes reviewed output

### Honest research flow without parallel runtime support
1. research-coordinator dispatches `scout`
2. research-coordinator dispatches `planner`
3. research-coordinator dispatches `plan-reviewer`
4. research-coordinator synthesizes the results

### Research flow with explicit parallel support
1. use the explicit supported parallel mechanism
2. ask independent research questions only
3. collect all results
4. synthesize and validate important disagreements

## Limitations

- Generic parallel dispatch is not assumed.
- Subprocess-based agent execution adds latency.
- Team definitions are only as reliable as the installed/local agent catalog.
- Legacy `ag-*` teams may depend on packaged agents not visible as local files.
- Prompt-level orchestration does not replace runtime enforcement; truthfulness matters.

## Migration Notes

- Existing lightweight and legacy teams are preserved.
- New coordinator-oriented teams are added as practical entry points.
- Existing chains remain available; new coordinator-centric chains are additive.
- Pi-specific expert orchestration remains separate in `pi-pi/pi-orchestrator.md`.
