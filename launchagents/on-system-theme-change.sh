#!/usr/bin/env bash
set -euo pipefail

# Ensure scripts are executable if present
[ -f "$HOME/.config/helix/theme_switcher.sh" ] && chmod +x "$HOME/.config/helix/theme_switcher.sh" || true
[ -f "$HOME/.config/zellij/theme_switcher.sh" ] && chmod +x "$HOME/.config/zellij/theme_switcher.sh" || true

# Trigger editors/term tools theme switchers
if [ -x "$HOME/.config/helix/theme_switcher.sh" ]; then
  "$HOME/.config/helix/theme_switcher.sh" || true
fi
if [ -x "$HOME/.config/zellij/theme_switcher.sh" ]; then
  "$HOME/.config/zellij/theme_switcher.sh" || true
fi

exit 0

