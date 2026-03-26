# OpenCode ntfy mobile notifications

## Plugin location

The ntfy integration is loaded as a local plugin file from:

```text
~/.config/opencode/plugins/ntfy.js
```

This avoids host-specific absolute paths in `opencode.json` and is portable across different usernames and machines.

## Required phone setup

1. Install the **ntfy** app on your phone.
2. Subscribe to the same topic configured in `OPENCODE_NTFY_TOPIC`.

## Required environment variables

- `OPENCODE_NTFY_TOPIC` — required; random topic name used for publishing/subscribing.
- `OPENCODE_NTFY_SERVER` — optional; defaults to `https://ntfy.sh`.
- `OPENCODE_NTFY_TOKEN` — optional; access token for protected topics.
- `OPENCODE_NTFY_PRIORITY` — optional; defaults to `high`.
- `OPENCODE_NTFY_TAGS` — optional; comma-separated ntfy tags, defaults to `computer`.
- `OPENCODE_NTFY_CLICK` — optional; URL opened when the notification is tapped.
- `OPENCODE_NTFY_SETTLE_MS` — optional; defaults to `4000`, lets OpenCode wait briefly before deciding whether all related work is truly quiet.
- `OPENCODE_NTFY_REQUIRE_QUIET_PTY` — optional; defaults to `false`. Set to `true` only if you want running OpenCode PTY sessions to suppress notifications too.
- `OPENCODE_NTFY_DEBUG` — optional; defaults to `false`. When `true`, the plugin appends decision logs to `~/.config/opencode/plugins/ntfy-debug.log`.

## Example

```bash
export OPENCODE_NTFY_TOPIC="opencode-please-change-me-12345"
export OPENCODE_NTFY_SERVER="https://ntfy.sh"
export OPENCODE_NTFY_PRIORITY="high"
export OPENCODE_NTFY_TAGS="computer,robot"
export OPENCODE_NTFY_SETTLE_MS="4000"
export OPENCODE_NTFY_REQUIRE_QUIET_PTY="false"
export OPENCODE_NTFY_DEBUG="true"
```

## Runtime files

The plugin may create local runtime files here:

- `~/.config/opencode/plugins/ntfy-debug.log`
- `~/.config/opencode/plugins/ntfy-state.json`

These are local artifacts and are not meant to be committed.
