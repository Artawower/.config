#!/usr/bin/env bash
set -euo pipefail

AGENT_ID="com.user.system-theme-watcher"
SRC_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
DEST_DIR="$HOME/Library/LaunchAgents"
PLIST_SRC="$SRC_DIR/system-theme-watcher.plist"
PLIST_DST="$DEST_DIR/$AGENT_ID.plist"

mkdir -p "$DEST_DIR"

echo "Installing LaunchAgent $AGENT_ID …"
if [ -f "$PLIST_DST" ]; then
  launchctl unload "$PLIST_DST" 2>/dev/null || true
fi

cp "$PLIST_SRC" "$PLIST_DST"

# Ensure scripts are executable
chmod +x "$SRC_DIR/on-system-theme-change.sh" || true
[ -f "$HOME/.config/helix/theme_switcher.sh" ] && chmod +x "$HOME/.config/helix/theme_switcher.sh" || true
[ -f "$HOME/.config/zellij/theme_switcher.sh" ] && chmod +x "$HOME/.config/zellij/theme_switcher.sh" || true

launchctl load -w "$PLIST_DST"
echo "Loaded $PLIST_DST"
echo "Done."

