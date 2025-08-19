#!/usr/bin/env bash
# Automatic theme switcher for Zellij based on system appearance

set -euo pipefail

get_system_theme() {
  if command -v osascript >/dev/null 2>&1; then
    local dark
    dark=$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')
    if [ "$dark" = "true" ]; then echo dark; else echo light; fi
  elif command -v gsettings >/dev/null 2>&1; then
    local theme
    theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "")
    if [[ "$theme" == *dark* ]]; then echo dark; else echo light; fi
  else
    local hour
    hour=$(date +%H)
    if [ "$hour" -ge 18 ] || [ "$hour" -le 6 ]; then echo dark; else echo light; fi
  fi
}

set_zellij_theme() {
  local system_theme new_theme config_file
  system_theme=$(get_system_theme)
  config_file="$HOME/.config/zellij/config.kdl"
  if [ "$system_theme" = dark ]; then
    new_theme='theme "catppuccin-frappe"'
  else
    new_theme='theme "catppuccin-latte"'
  fi

  if [ ! -f "$config_file" ]; then
    return 0
  fi

  cp "$config_file" "$config_file.bak" 2>/dev/null || true

  # Prefer POSIX grep to avoid PATH issues under launchd
  if grep -Eq '^[[:space:]]*theme[[:space:]]+"[^"]+"' "$config_file"; then
    if sed --version >/dev/null 2>&1; then
      # GNU sed
      sed -i -E "s|^[[:space:]]*theme[[:space:]]+\"[^\"]+\"|$new_theme|" "$config_file"
    else
      # BSD sed (macOS)
      sed -i '' -E "s|^[[:space:]]*theme[[:space:]]+\"[^\"]+\"|$new_theme|" "$config_file"
    fi
  else
    printf "\n%s\n" "$new_theme" >> "$config_file"
  fi
}

set_zellij_theme || true
