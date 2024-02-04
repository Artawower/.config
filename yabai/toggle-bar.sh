#!/bin/sh


# is_started=$(brew services list | grep sketchybar | awk '{ print $2}')

# echo $is_started

is_hidden=$(sketchybar --query bar | jq '.hidden')

echo $is_hidden

if [ "$is_hidden" == "\"off\"" ]; then
  sketchybar --bar hidden=on
  yabai -m config top_padding 40
  yabai -m config bottom_padding               40
  yabai -m config left_padding                 40
  yabai -m config right_padding                40
  yabai -m config window_gap                   40
else
  sketchybar --bar hidden=off
  yabai -m config top_padding 68
fi
