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
