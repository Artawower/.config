#! /usr/bin/env zsh

for idx in $( yabai -m query --spaces | jq '.[] | .index' ); do
  yabai -m space --focus $idx
done

# Go back
yabai -m space --focus 1
