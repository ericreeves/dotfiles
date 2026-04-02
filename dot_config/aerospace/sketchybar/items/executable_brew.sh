#!/bin/bash

sketchybar --add item brew right \
  --set brew \
    icon="$ICON_BREW" \
    icon.font="$NERD_FONT:Bold:16.0" \
    icon.color=$SUBTLE \
    label.color=$TEXT_COLOR \
    label.font="$FONT:Regular:12.0" \
    background.drawing=off \
    update_freq=1800 \
    script="$PLUGIN_DIR/brew.sh"
