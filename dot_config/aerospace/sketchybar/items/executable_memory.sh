#!/bin/bash

sketchybar --add item memory right \
  --set memory \
    icon="$ICON_MEM" \
    icon.font="$NERD_FONT:Bold:16.0" \
    icon.color=$SUBTLE \
    label.color=$TEXT_COLOR \
    label.font="$FONT:Regular:12.0" \
    background.drawing=off \
    update_freq=10 \
    script="$PLUGIN_DIR/memory.sh"
