#!/usr/bin/env bash

set_opacity() {
    if defaults read -g AppleInterfaceStyle &>/dev/null; then
        # Dark mode
        yabai -m config active_window_opacity 0.95
    else
        # Light mode
        yabai -m config active_window_opacity 1.0
    fi
}

set_opacity

while true; do
    defaults read -g AppleInterfaceStyle &>/dev/null
    CURRENT=$?
    sleep 5
    defaults read -g AppleInterfaceStyle &>/dev/null
    NEW=$?
    if [ "$CURRENT" != "$NEW" ]; then
        set_opacity
    fi
done
