#!/bin/bash

# Lightweight focus-change handler for dynamic gaps.
# Detects window count changes on the current workspace:
#   - Was centered, now 2+ windows → retile
#   - Was tiled, now 1 window → center (delegates to full script)
# No centering logic here — delegates to dynamic_gaps.sh when needed.

STATE_DIR="/tmp/aerospace_dynamic_gaps"

WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
[ -z "$WORKSPACE" ] && exit 0

STATE_FILE="$STATE_DIR/ws_${WORKSPACE}"
PREV_STATE=$(cat "$STATE_FILE" 2>/dev/null)

# Quick window count
COUNT=$(aerospace list-windows --workspace "$WORKSPACE" --count 2>/dev/null)

if echo "$PREV_STATE" | grep -q "^centered" && [ "${COUNT:-0}" -ge 2 ]; then
  # Was centered, now 2+ windows → retile all
  for wid in $(aerospace list-windows --workspace "$WORKSPACE" --format '%{window-id}' 2>/dev/null); do
    aerospace layout --window-id "$wid" tiling 2>/dev/null || true
  done
  echo "tiled $COUNT" > "$STATE_FILE"

elif echo "$PREV_STATE" | grep -q "^tiled" && [ "${COUNT:-0}" -le 1 ]; then
  # Was tiled, now 1 window → delegate to full centering script
  rm -f "$STATE_FILE"
  exec "$HOME/.config/aerospace/sketchybar/plugins/dynamic_gaps.sh"
fi
