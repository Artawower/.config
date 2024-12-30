#!/bin/sh

# is_started=$(brew services list | grep sketchybar | awk '{ print $2}')

# echo $is_started

is_hidden=$(sketchybar --query bar | jq '.hidden')

echo $is_hidden

bash ~/.config/yabai/stack-windows.sh

# Function for hide bar 

if [ "$is_hidden" == "\"off\"" ]; then
    sketchybar --bar hidden=on
    yabai -m config top_padding 8
    yabai -m config bottom_padding 8
    yabai -m config left_padding 8
    yabai -m config right_padding 8
    yabai -m config window_gap 8
    # yabai -m rule --apply app="^spotube$" manage=off grid=100:100:3:5:60:80 space=6
    yabai -m rule --apply app="^spotube$" manage=off grid=100:100:5:7:84:84 space=6
    yabai -m rule --apply app="^iPhone Mirroring$" manage=off grid=100:100:72:20:10:10 space=7
    YABAI -m rule --apply app="^Session$" manage=off grid=100:100:68:28:0:40 space=7
    yabai -m rule --apply app="^Session$" manage=off grid=100:100:66:28:30:40 space=7
    yabai -m rule --apply app="^TickTick$" manage=off grid=100:100:3:5:56:80 space=7

    yabai -m space 1 --gap rel:32
    yabai -m space 1 --padding abs:32:32:32:32

    yabai -m space 2 --gap rel:32
    yabai -m space 2 --padding abs:64:64:64:64
    yabai -m space 5 --padding abs:20:20:20:20
    # borders blacklist="Loom,qemu-system-aarch64" active_color=0xffe78284 inactive_color=0xfff2d5cf width=0 2>/dev/null 1>&2 &
else
    sketchybar --bar hidden=off
    yabai -m config top_padding 62
    yabai -m config bottom_padding 20
    yabai -m config left_padding 20
    yabai -m config right_padding 20
    yabai -m config window_gap 20
    borders blacklist="Loom,qemu-system-aarch64" active_color=0xffe78284 inactive_color=0xfff2d5cf width=5.0 2>/dev/null 1>&2 &
fi

yabai -m rule --apply app="^NeoHtop$" manage=off grid=100:100:1:1:98:98
