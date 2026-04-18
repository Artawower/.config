# System Configuration Notes

## Environment: Asahi Linux (Fedora) + Niri compositor, MacBook Pro (Apple Silicon)

### Shell: xonsh (from Nix store)
- Config: `~/.config/xonsh/rc.xsh` sources modular files from `~/.config/xonsh/`
- PATH setup: `~/.config/xonsh/paths.xsh`

### Nix + Fedora coexistence
- Home Manager manages Nix packages (`~/.config/home-manager/home.nix`, flake-based, `nixos-23.05`)
- `hm-session-vars.sh` is sourced in `rc.xsh` — it sets env vars like `LD_LIBRARY_PATH`, `CPATH`, `LIBCLANG_PATH`
- **Problem**: Nix's `LD_LIBRARY_PATH` breaks Fedora system binaries (e.g. `libz` version mismatch in binutils)
- **Fix applied** in `rc.xsh`: `del $LD_LIBRARY_PATH` on Linux after sourcing hm-session-vars. Nix binaries use RPATH, don't need it.
- **PATH priority**: Fedora `/usr/bin` before Nix `~/.nix-profile/bin` (configured in `paths.xsh`)
- GPU/Mesa/kernel must come from Fedora (Asahi drivers not in Nix)

### Touchpad: trackpad-is-too-damn-big (titdb)
- **What**: Palm rejection / edge activation limiter for Apple trackpad, mimics macOS behavior
- **Why**: Default libinput palm detection insufficient; taps trigger during typing, edges too sensitive
- **Source**: https://github.com/tascvh/trackpad-is-too-damn-big
- **Build deps**: `sudo dnf install cmake gcc gcc-c++ libevdev-devel`
- **Built from**: `~/tmp/trackpad-is-too-damn-big/build/trackpad-is-too-damn-big/`
- **Installed to**: `/usr/local/bin/titdb`
- **Device**: `/dev/input/by-path/platform-39b10c000.spi-cs-0-event-mouse` (Apple SPI Trackpad, event0)
- **Systemd**: `/etc/systemd/system/titdb.service` — `sudo systemctl enable --now titdb.service`
- **Rebuild**: `cd ~/tmp/trackpad-is-too-damn-big/build/trackpad-is-too-damn-big/build && cmake .. && make`

### Other touchpad tuning (not yet applied)
- `libinput-config` — scroll speed factor (`/etc/libinput.conf`, `scroll-factor=0.5`)
- Niri touchpad config in `~/.config/niri/config.kdl`: `dwt` (disable while typing), `accel-speed`, `accel-profile`

### Colemak HNEI Navigation (REQUIRED in Neovim)
- **Rule**: All navigation in Neovim must use Colemak layout
- `h` → left (was `h`)
- `n` → down (was `j`)
- `e` → up (was `k`)
- `i` → right (was `l`)
- **Exception**: Search (`n`/`N` for next/prev search result stays QWERTY)

---

## Orchestration Policy

### Scope
- `AGENTS.md` defines **global runtime, environment, safety, and orchestration policy** for this repository.
- Agent personas, team composition, and workflow chains belong in `.pi/agents/*.md`, `.pi/agents/teams.yaml`, and `.pi/agents/agent-chain.yaml`.
- Runtime behavior exposed by extensions is authoritative over prompt assumptions.

### Coordinator / Orchestrator Boundary
- A coordinator/orchestrator agent is allowed to decompose tasks, choose specialists, dispatch work, and synthesize results.
- A dispatcher-only coordinator must **not** claim direct inspection or modification of the codebase unless it actually has those tools.
- Specialist agents own the actual work inside their domain boundaries: recon, planning, implementation, review, adversarial analysis, or documentation.

### Sequential by Default
- Assume orchestration is **sequential by default** unless the runtime exposes an explicit batch or concurrent execution path.
- One dispatch should target one agent with one focused task.
- Coordinators should wait for each result before deciding the next step.
- Do not imply generic parallel fan-out if the runtime only exposes one-agent dispatch.

### Limited Parallel Policy
- Parallel work is allowed only when an explicit tool or runtime path supports it.
- Parallel fan-out is best reserved for independent research-style work where results can be synthesized safely.
- If explicit parallel support is unavailable, coordinators must fall back to sequential delegation and say so honestly.

### Responsibility Split
- Put **repo-wide constraints** here: environment quirks, VCS rules, security defaults, orchestration truthfulness, runtime limitations.
- Put **agent-specific behavior** in agent definition files.
- Put **team membership** in `teams.yaml`.
- Put **standard sequential pipelines** in `agent-chain.yaml`.

### Truthfulness Rules
- Never promise unsupported runtime behavior.
- Never describe generic parallel dispatch as available unless a real tool/runtime path exists.
- When results conflict, route them to reviewer/critic-style agents instead of silently picking a winner.
- When the runtime or team cannot satisfy a request, state the limitation explicitly.

# context-mode — MANDATORY routing rules

You have context-mode MCP tools available. These rules are NOT optional — they protect your context window from flooding. A single unrouted command can dump 56 KB into context and waste the entire session.

## BLOCKED commands — do NOT attempt these

### curl / wget — BLOCKED
Any shell command containing `curl` or `wget` will be intercepted and blocked by the context-mode plugin. Do NOT retry.
Instead use:
- `context_mode_ctx_fetch_and_index(url, source)` to fetch and index web pages
- `context_mode_ctx_execute(language: "javascript", code: "const r = await fetch(...)")` to run HTTP calls in sandbox

### Inline HTTP — BLOCKED
Any shell command containing `fetch('http`, `requests.get(`, `requests.post(`, `http.get(`, or `http.request(` will be intercepted and blocked. Do NOT retry with shell.
Instead use:
- `context_mode_ctx_execute(language, code)` to run HTTP calls in sandbox — only stdout enters context

### Direct web fetching — BLOCKED
Do NOT use any direct URL fetching tool. Use the sandbox equivalent.
Instead use:
- `context_mode_ctx_fetch_and_index(url, source)` then `context_mode_ctx_search(queries)` to query the indexed content

## REDIRECTED tools — use sandbox equivalents

### Shell (>20 lines output)
Shell is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`, and other short-output commands.
For everything else, use:
- `context_mode_ctx_batch_execute(commands, queries)` — run multiple commands + search in ONE call
- `context_mode_ctx_execute(language: "shell", code: "...")` — run in sandbox, only stdout enters context

### File reading (for analysis)
If you are reading a file to **edit** it → reading is correct (edit needs content in context).
If you are reading to **analyze, explore, or summarize** → use `context_mode_ctx_execute_file(path, language, code)` instead. Only your printed summary enters context.

### grep / search (large results)
Search results can flood context. Use `context_mode_ctx_execute(language: "shell", code: "grep ...")` to run searches in sandbox. Only your printed summary enters context.

## Tool selection hierarchy

1. **GATHER**: `context_mode_ctx_batch_execute(commands, queries)` — Primary tool. Runs all commands, auto-indexes all output, returns search results. ONE call replaces 30+ individual calls.
2. **FOLLOW-UP**: `context_mode_ctx_search(queries: ["q1", "q2", ...])` — Query indexed content. Pass ALL questions as array in ONE call.
3. **PROCESSING**: `context_mode_ctx_execute(language, code)` | `context_mode_ctx_execute_file(path, language, code)` — Sandbox execution. Only stdout enters context.
4. **WEB**: `context_mode_ctx_fetch_and_index(url, source)` then `context_mode_ctx_search(queries)` — Fetch, chunk, index, query. Raw HTML never enters context.

## Output constraints

- Keep responses under 500 words.
- Write artifacts (code, configs, PRDs) to FILES — never return them as inline text. Return only: file path + 1-line description.
- When indexing content, use descriptive source labels so others can `search(source: "label")` later.

## ctx commands

| Command | Action |
|---------|--------|
| `ctx stats` | Call the `stats` MCP tool and display the full output verbatim |
| `ctx doctor` | Call the `doctor` MCP tool, run the returned shell command, display as checklist |
| `ctx upgrade` | Call the `upgrade` MCP tool, run the returned shell command, display as checklist |