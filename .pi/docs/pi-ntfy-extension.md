# Pi ntfy notification extension

## What it does

This project-local Pi extension sends `ntfy` push notifications when Pi finishes a prompt and appears to be waiting on you.

It also observes `session_shutdown`, but only as a secondary chance to deliver the same pending user-attention notification if Pi is shutting down immediately after a relevant turn. It does not send unconditional shutdown alerts.

It is intentionally minimal and Pi-native:

- implemented as a local tracked extension in `.pi/extensions/pi-ntfy.ts`
- uses Pi lifecycle hooks: `turn_end`, `agent_end`, and `session_shutdown`
- follows the existing OpenCode ntfy conventions where they fit: env-driven config, ntfy headers, dedupe state file, optional debug log, and simple user-attention heuristics
- avoids extra package setup or nonessential abstractions

## Files

Tracked:

- `.pi/extensions/pi-ntfy.ts`
- `.pi/docs/pi-ntfy-extension.md`

Local runtime artifacts created on demand:

- `.pi/extensions/pi-ntfy-debug.log`
- `.pi/extensions/pi-ntfy-state.json`

## Configuration

Set these environment variables before starting Pi.

Pi first checks `PI_NTFY_*`. If a given `PI_NTFY_*` variable is unset, it falls back to the matching `OPENCODE_NTFY_*` variable. This lets Pi and opencode share one ntfy configuration when desired.

Supported names:

- `PI_NTFY_TOPIC` / `OPENCODE_NTFY_TOPIC` — required; your ntfy topic
- `PI_NTFY_SERVER` / `OPENCODE_NTFY_SERVER` — optional; defaults to `https://ntfy.sh`
- `PI_NTFY_TOKEN` / `OPENCODE_NTFY_TOKEN` — optional; token for protected topics
- `PI_NTFY_PRIORITY` / `OPENCODE_NTFY_PRIORITY` — optional; defaults to `high`
- `PI_NTFY_TAGS` / `OPENCODE_NTFY_TAGS` — optional; comma-separated tags, defaults to `computer`
- `PI_NTFY_CLICK` / `OPENCODE_NTFY_CLICK` — optional; URL to open on tap
- `PI_NTFY_SETTLE_MS` / `OPENCODE_NTFY_SETTLE_MS` — optional; defaults to `4000`; invalid/negative values fall back to the default, and large values are capped at `30000`
- `PI_NTFY_DEBUG` / `OPENCODE_NTFY_DEBUG` — optional; set to `true` to append debug decisions to `.pi/extensions/pi-ntfy-debug.log`

Note: `OPENCODE_NTFY_REQUIRE_QUIET_PTY` is an opencode-specific option and is not used by this Pi extension.

Example:

```bash
export OPENCODE_NTFY_TOPIC="shared-please-change-me-12345"
export OPENCODE_NTFY_SERVER="https://ntfy.sh"
export OPENCODE_NTFY_PRIORITY="high"
export OPENCODE_NTFY_TAGS="computer,robot"
export OPENCODE_NTFY_SETTLE_MS="4000"

# Optional Pi-only override
export PI_NTFY_DEBUG="true"
```

## Loading

Pi auto-discovers project-local extensions from `.pi/extensions/`.

If needed for an explicit one-off run:

```bash
pi -e .pi/extensions/pi-ntfy.ts
```

Then subscribe to the same topic in the ntfy mobile app.

## Notification behavior

The extension tries to notify only when Pi likely wants user attention:

- questions
- clarification / confirmation requests
- choice / approval prompts
- explicit “waiting on you” style phrasing

`session_shutdown` is only used as a fallback path for the same fresh, attention-worthy latest turn. This avoids misleading shutdown-only notifications and reduces duplicate sends between `agent_end` and `session_shutdown`.

The extension also ignores stale turns older than a short freshness window, so old assistant text is less likely to trigger notifications during unrelated shutdowns.

To avoid repeats, the extension stores a small per-session dedupe record in `.pi/extensions/pi-ntfy-state.json`.

## Privacy notes

ntfy receives the notification body and selected headers. In this extension that means:

- body: a truncated copy of the latest assistant text that looked like a user-attention request
- `Title`: `Pi · <project-name>`
- `Tags`: configured tags
- `Priority`: configured priority
- `Click`: configured click URL, if set
- `Authorization`: token header, if set

If your assistant messages may contain sensitive information, use a private ntfy server/topic and treat notification content as potentially visible on your lock screen / mobile device.
