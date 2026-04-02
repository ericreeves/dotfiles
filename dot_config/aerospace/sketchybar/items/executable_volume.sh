#!/bin/bash

sketchybar --add item volume right \
  --set volume \
    icon="$ICON_VOL_HIGH" \
    icon.font="$NERD_FONT:Bold:16.0" \
    icon.color=$SUBTLE \
    label.color=$TEXT_COLOR \
    label.font="$FONT:Regular:12.0" \
    background.drawing=off \
    script="$PLUGIN_DIR/volume.sh" \
    click_script="osascript -e 'set volume output muted (not (output muted of (get volume settings)))' && sketchybar --trigger volume_change" \
  --subscribe volume volume_change
