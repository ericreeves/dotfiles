#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

BATT_INFO=$(pmset -g batt)
PERCENT=$(echo "$BATT_INFO" | grep -o '[0-9]*%' | head -1 | tr -d '%')
CHARGING=$(echo "$BATT_INFO" | grep -q 'AC Power' && echo "true" || echo "false")

if [ -z "$PERCENT" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$CHARGING" = "true" ]; then
  ICON="$ICON_BAT_CHARGING"
  COLOR=$GREEN
elif [ "$PERCENT" -gt 80 ]; then
  ICON="$ICON_BAT_100"
  COLOR=$GREEN
elif [ "$PERCENT" -gt 50 ]; then
  ICON="$ICON_BAT_75"
  COLOR=$YELLOW
elif [ "$PERCENT" -gt 25 ]; then
  ICON="$ICON_BAT_50"
  COLOR=$ORANGE
else
  ICON="$ICON_BAT_25"
  COLOR=$RED
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENT}%"
