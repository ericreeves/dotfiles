#!/bin/bash

sketchybar --add item battery right \
  --set battery \
    icon.font="$NERD_FONT:Bold:16.0" \
    icon.color=$GREEN \
    label.font="$FONT:Regular:12.0" \
    background.drawing=off \
    update_freq=120 \
    script="$PLUGIN_DIR/battery.sh"
