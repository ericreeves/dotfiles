#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

ZEN_ITEMS=(apple cpu memory network brew battery volume)

# Check current state via sketchybar query
DRAWING=$(sketchybar --query cpu | python3 -c "import sys,json; print(json.load(sys.stdin)['geometry']['drawing'])" 2>/dev/null)

if [ "$DRAWING" = "on" ]; then
  # Enter zen mode — hide items
  for item in "${ZEN_ITEMS[@]}"; do
    sketchybar --set "$item" drawing=off
  done
  sketchybar --set calendar icon="$ICON_ZEN"
else
  # Exit zen mode — show items
  for item in "${ZEN_ITEMS[@]}"; do
    sketchybar --set "$item" drawing=on
  done
  sketchybar --set calendar icon="$ICON_CLOCK"
fi
