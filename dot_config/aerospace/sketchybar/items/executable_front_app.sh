#!/bin/bash

sketchybar --add item front_app left \
  --set front_app \
    icon.drawing=on \
    icon.font="sketchybar-app-font:Regular:16.0" \
    icon.color=$ACCENT_COLOR \
    icon.padding_left=4 \
    icon.padding_right=4 \
    label.font="$FONT:Semibold:12.0" \
    label.color=$ACCENT_COLOR \
    label.padding_left=4 \
    label.padding_right=8 \
    background.drawing=off \
    script="$PLUGIN_DIR/front_app.sh" \
    associated_display=active \
  --subscribe front_app front_app_switched
