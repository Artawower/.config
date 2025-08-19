#!/usr/bin/env bash
set -euo pipefail

AGENT_ID="com.user.system-theme-watcher"
PLIST_DST="$HOME/Library/LaunchAgents/$AGENT_ID.plist"

echo "Uninstalling LaunchAgent $AGENT_ID …"
if [ -f "$PLIST_DST" ]; then
  launchctl unload "$PLIST_DST" 2>/dev/null || true
  rm -f "$PLIST_DST"
  echo "Removed $PLIST_DST"
else
  echo "No plist at $PLIST_DST"
fi
echo "Done."

