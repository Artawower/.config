LaunchAgents bundle

What it is
- system-theme-watcher: a macOS LaunchAgent that reacts to system appearance changes and triggers theme switchers for Helix and Zellij.

Files
- system-theme-watcher.plist: LaunchAgent definition (copied to ~/Library/LaunchAgents/com.user.system-theme-watcher.plist).
- on-system-theme-change.sh: Hook script that calls:
  - ~/.config/helix/theme_switcher.sh
  - ~/.config/zellij/theme_switcher.sh
- install.sh / uninstall.sh: helpers to (un)install the LaunchAgent.

Install
1) Run: sh ~/.config/launchagents/install.sh
   - This copies the plist, fixes execute bits, and loads the agent.

Uninstall
1) Run: sh ~/.config/launchagents/uninstall.sh

Notes
- Zellij hot-reloads config; changing `theme "..."` in ~/.config/zellij/config.kdl applies immediately.
- Helix needs :config-reload (or restart) to apply theme in an already running instance.
- Scripts are idempotent and safe to run multiple times.

