#!/bin/bash

sketchybar --add item cpu right \
  --set cpu \
    icon="$ICON_CPU" \
    icon.font="$NERD_FONT:Bold:16.0" \
    icon.color=$SUBTLE \
    label.color=$TEXT_COLOR \
    label.font="$FONT:Regular:12.0" \
    background.drawing=off \
    update_freq=5 \
    script="$PLUGIN_DIR/cpu.sh"
