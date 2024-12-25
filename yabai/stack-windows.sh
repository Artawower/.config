#!/bin/bash

yabai -m query --windows --space 1 | jq -c '.[]' | while read -r window; do
    floating=$(echo "$window" | jq -r '.["is-floating"]')
    id=$(echo "$window" | jq -r '.id')

    if [ "$floating" = "true" ]; then
        echo "Toggling float mode off for window $id"
        yabai -m window "$id" --toggle float # Toggle float mode if needed
    fi
done

sleep 1

# Step 2: Get the ID of the first window in Space 1
first_window_id=$(yabai -m query --windows --space 1 | jq -re '.[0].id')
echo "First window ID: $first_window_id"

# Step 3: Stack all other windows onto the first window and print the app name
yabai -m query --windows --space 1 | jq -c '.[]' | while read -r window; do
    id=$(echo "$window" | jq -r '.id')
    app=$(echo "$window" | jq -r '.app')

    echo "Window ID: $id, Application: $app, floating: $floating" # Print each window's ID and app name

    if [ "$id" != "$first_window_id" ]; then
        echo "Stacking window $id onto window $first_window_id" # Debug statement
        yabai -m window "$id" --stack "$first_window_id"
    fi
done
