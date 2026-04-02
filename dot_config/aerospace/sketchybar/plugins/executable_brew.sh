#!/bin/bash

source "$CONFIG_DIR/colors.sh"

COUNT=$(brew outdated -q 2>/dev/null | wc -l | tr -d ' ')

if [ "$COUNT" -eq 0 ] 2>/dev/null; then
  sketchybar --set "$NAME" label="0" icon.color=$GREEN label.color=$GREEN
elif [ "$COUNT" -lt 10 ]; then
  sketchybar --set "$NAME" label="$COUNT" icon.color=$SUBTLE label.color=$TEXT_COLOR
elif [ "$COUNT" -lt 30 ]; then
  sketchybar --set "$NAME" label="$COUNT" icon.color=$YELLOW label.color=$YELLOW
else
  sketchybar --set "$NAME" label="$COUNT" icon.color=$ORANGE label.color=$ORANGE
fi
