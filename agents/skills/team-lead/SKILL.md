---
name: team-lead
description: Orchestrate multiple AI coding agents via pi-link and cmux. Use when user wants to coordinate multiple AI agents, assign roles (researcher, coder, reviewer), or mentions "team", "orchestrate", "delegate", or "multiple agents".
---

# Team Lead Skill

Execute this workflow immediately when the user runs `/team-lead`.

Goal: ensure the current project has exactly these roles in the active pi-link network for the current cwd:

- `<ir>@team-lead` — the current session
- `<ir>@researcher`
- `<ir>@coder`
- `<ir>@reviewer`

`<ir>` is `basename("$(pwd)")`.

## Command boundary

Treat these as two different execution channels.

### Pi slash commands — never run through bash

These commands must be entered as Pi commands inside the current Pi session:

- `/link`
- `/link-connect`
- `/link-name <name>`
- `/team-lead`

If one of these is run through shell and you see `/bin/bash: /link: No such file or directory`, that is a workflow error. Stop and retry it as a Pi slash command, not as a shell command.

### Shell commands — only through bash

These commands are shell commands and must be run through bash:

- `cmux current-workspace`
- `python3 ~/.config/agents/skills/team-lead/spawn-agent.py ...`

### Forbidden pseudo-APIs

Do not use invented helpers or pseudo-tools such as:

- `link_list`
- `link_send`
- `link_prompt`
- any other `link_*` command that is not an actual Pi slash command

The only supported link control surface for this skill is the Pi slash-command interface: `/link`, `/link-connect`, `/link-name`.


## Rules

- Use `/link` as the source of truth for the roster.
- Create missing peers only in the current cmux workspace.
- Create new peers as `surface`, not workspace.
- Use the Python helper for cmux automation. Do not reproduce its low-level logic manually unless debugging it.
- Never run `/link`, `/link-connect`, or `/link-name` through bash.
- Never use `link_list`, `link_send`, `link_prompt`, or any other invented `link_*` API.
- After each spawned role, re-run `/link` and verify the role appeared for the current cwd.
- If the hub assigned a suffixed name like `-2`, report it as a conflict instead of pretending the exact role exists.

## Prerequisites

This skill must run inside a pi session. If cmux is unavailable, stop and tell the user.

Check cmux with bash:

```bash
cmux current-workspace
```

Use the helper at:

```bash
python3 ~/.config/agents/skills/team-lead/spawn-agent.py
python3 ~/.config/agents/skills/team-lead/launch-team.py
```

If the slash-command flow is unreliable in your environment, use the deterministic standalone launcher instead:

```bash
python3 ~/.config/agents/skills/team-lead/launch-team.py
python3 ~/.config/agents/skills/team-lead/launch-team.py --force
```

Run it from any current cmux-hosted terminal. It will:

- spawn dedicated pi surfaces for all four roles: `team-lead`, `researcher`, `coder`, `reviewer`;
- start missing role surfaces in parallel, not one-by-one;
- `cd` each new surface into the caller's current working directory before starting pi;
- reuse an existing role tab only when all three checks pass: the tab title is exactly `<ir>@<role>`, pi is still running in that tab, and pi reports the exact same `link:` identity;
- treat same-title tabs without a live matching pi session as stale and recreate them;
- close the initiating cmux shell tab after a successful run, unless that tab is itself one of the kept role tabs;
- with `--force`, close existing team-role tabs in the workspace and recreate them cleanly.


## Workflow

### 1. Normalize the current session

1. Compute `<ir>` from the current working directory.
2. Run `/link-connect`.
3. Run `/link-name <ir>@team-lead`.
4. Run `/link` and inspect only terminals whose `cwd` matches the current project directory.

### 2. Compute missing roles

Required exact names:

- `<ir>@team-lead`
- `<ir>@researcher`
- `<ir>@coder`
- `<ir>@reviewer`

If a required role is already present for the current cwd, do not recreate it.

### 3. Resolve the current cmux workspace

Prefer `CMUX_WORKSPACE_ID`. If it is not set, get it with:

```bash
cmux current-workspace
```

Use that exact workspace for all helper invocations.

### 4. Spawn each missing role

For every missing role, run the helper via bash:

```bash
python3 ~/.config/agents/skills/team-lead/spawn-agent.py <role> <ir> <workspace-id> <project-dir>
```

The helper is responsible for:

- creating a new terminal surface;
- resolving the created surface UUID;
- waiting until the surface is ready;
- launching `pi --link`;
- waiting until pi looks ready for slash commands;
- sending `/link-name <ir>@<role>`;
- falling back to `/link-connect` only if needed;
- renaming the cmux surface/tab to `<ir>@<role>`;
- failing loudly instead of guessing.

### 5. Verify after each spawn

After every helper run:

1. Run `/link`.
2. Confirm the expected `<ir>@<role>` now exists for the current cwd.
3. If it does not appear, stop and report which role failed.

### 6. Final output

When complete, report the final roster for the current project:

```text
Team: <ir>
  • <ir>@team-lead (you)
  • <ir>@researcher
  • <ir>@coder
  • <ir>@reviewer
```

## Failure handling

- If `cmux current-workspace` fails, stop: cmux is not available.
- If `/link` shows terminals from other directories, ignore them.
- If the helper exits with JSON `{ "status": "error", ... }`, surface that error to the user.
- If `/link` shows `<ir>@role-2` instead of the requested exact name, report a role-name conflict.
- Do not claim success until `/link` confirms the full roster for the current cwd.