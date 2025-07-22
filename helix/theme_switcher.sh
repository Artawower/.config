#!/usr/bin/env bash
# Automatic theme switcher for Helix based on macOS system appearance

# Get current system appearance on macOS
get_system_theme() {
    if command -v osascript >/dev/null 2>&1; then
        # macOS
        theme=$(osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode')
        if [ "$theme" = "true" ]; then
            echo "dark"
        else
            echo "light"
        fi
    elif command -v gsettings >/dev/null 2>&1; then
        # Linux with GNOME
        theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "")
        if [[ "$theme" == *"dark"* ]]; then
            echo "dark"
        else
            echo "light"
        fi
    else
        # Fallback - check time of day
        hour=$(date +%H)
        if [ "$hour" -ge 18 ] || [ "$hour" -le 6 ]; then
            echo "dark"
        else
            echo "light"
        fi
    fi
}

# Set Helix theme based on system theme
set_helix_theme() {
    local system_theme=$(get_system_theme)
    local config_file="$HOME/.config/helix/config.toml"
    
    if [ "$system_theme" = "dark" ]; then
        # Dark transparent theme
        local new_theme="my"
    else
        # Light transparent theme  
        local new_theme="my_light"
    fi
    
    # Update config.toml
    if [ -f "$config_file" ]; then
        sed -i.backup "s/^theme = .*/theme = \"$new_theme\"/" "$config_file"
        echo "Switched Helix theme to: $new_theme (system: $system_theme)"
    else
        echo "Helix config file not found at: $config_file"
    fi
}

# Main execution
set_helix_theme