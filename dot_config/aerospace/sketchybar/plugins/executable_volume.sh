#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

VOL=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$MUTED" = "true" ] || [ "$VOL" -eq 0 ] 2>/dev/null; then
  ICON="$ICON_VOL_MUTE"
  COLOR=$RED
elif [ "$VOL" -gt 66 ]; then
  ICON="$ICON_VOL_HIGH"
  COLOR=$SUBTLE
elif [ "$VOL" -gt 33 ]; then
  ICON="$ICON_VOL_MED"
  COLOR=$SUBTLE
else
  ICON="$ICON_VOL_LOW"
  COLOR=$SUBTLE
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${VOL}%"
