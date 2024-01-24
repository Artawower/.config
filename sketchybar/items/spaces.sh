#!/bin/bash

# SPACE_ICONS=("social" "debug" "entertiment" "dev" "browser" "other" "trash" "8" "9" "10" "11" "12" "13" "14" "15")
SPACE_ICONS=("soc" "term" "www" "oth" "dev" "ent" "th" "8" "9" "10" "11" "12" "13" "14" "15")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sid=0
spaces=()
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))

  space=(
    associated_space=$sid
    icon=${SPACE_ICONS[i]}
    icon.padding_left=10
    icon.padding_right=10
    padding_left=2
    padding_right=5
    label.padding_right=14
    icon.highlight_color=$RED
    label.font="sketchybar-app-font:Regular:10.0"
    label.background.height=18
    label.background.drawing=on
    label.background.color=$BACKGROUND_2
    label.background.corner_radius=14
    label.y_offset=-1
    label.drawing=off
    script="$PLUGIN_DIR/space.sh"
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid mouse.clicked
done

spaces=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
  background.border_width=2
  background.drawing=on
)

separator=(
  icon=􀆊
  icon.font="$FONT:Heavy:10.0"
  padding_left=10
  padding_right=8
  label.drawing=off
  associated_display=active
  click_script='yabai -m space --create && sketchybar --trigger space_change'
  icon.color=$WHITE
)

sketchybar --add bracket spaces '/space\..*/' \
           --set spaces "${spaces[@]}"        \
                                              \
           # --add item separator left          \
           # --set separator "${separator[@]}"
