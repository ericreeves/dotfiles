#!/bin/bash

sketchybar --add item calendar right \
  --set calendar \
    icon="$ICON_CLOCK" \
    icon.font="$NERD_FONT:Bold:14.0" \
    icon.color=$SUBTLE \
    label.font="$FONT:Regular:12.0" \
    background.drawing=off \
    update_freq=30 \
    click_script="$PLUGIN_DIR/zen.sh" \
    script="$PLUGIN_DIR/calendar.sh"
