#! /usr/bin/env zsh

events=('application_launched')
apps=('Reminders' 'System Preferences')

read -r -d '' action <<- 'EOF'
  window="$(yabai -m query --windows --window)"
  display="$(yabai -m query --displays --window)"
  coords="$(jq \
    --argjson window "${window}" \
    --argjson display "${display}" \
    -nr '(($display.frame | .x + .w / 2) - ($window.frame.w / 2) | tostring)
      + ":"
      + (($display.frame | .y + .h / 2) - ($window.frame.h / 2) | tostring)')"
  yabai -m window --move "abs:${coords}"
EOF

(( ${#apps[@]} ))   && app_query="app=\"^($(IFS=\|;echo "${apps[*]}"))\$\""
for event in "${events[@]}"; do
  yabai -m signal --add label="${0}_signal_${event}" event="${event}" \
    $(eval "${app_query}}") action="${action}"
done
