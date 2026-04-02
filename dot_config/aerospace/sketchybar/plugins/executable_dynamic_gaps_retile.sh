#!/bin/bash

# Lightweight focus-change handler for dynamic gaps.
# Detects window count changes on the current workspace:
#   - Was centered, now 2+ windows → retile all
#   - Was tiled/no state, now 1 window → center (delegates to full script)
#   - 2+ windows but some floating → retile all (catches cross-workspace moves)

STATE_DIR="/tmp/aerospace_dynamic_gaps"

WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
[ -z "$WORKSPACE" ] && exit 0

STATE_FILE="$STATE_DIR/ws_${WORKSPACE}"
PREV_STATE=$(cat "$STATE_FILE" 2>/dev/null)

# Quick window count
COUNT=$(aerospace list-windows --workspace "$WORKSPACE" --count 2>/dev/null)

if [ "${COUNT:-0}" -ge 2 ]; then
  # 2+ windows — ensure all are tiled (handles centered→multi AND floating arrivals)
  if echo "$PREV_STATE" | grep -q "^centered"; then
    for wid in $(aerospace list-windows --workspace "$WORKSPACE" --format '%{window-id}' 2>/dev/null); do
      aerospace layout --window-id "$wid" tiling 2>/dev/null || true
    done
    echo "tiled $COUNT" > "$STATE_FILE"
  fi

elif [ "${COUNT:-0}" -le 1 ]; then
  # 1 or 0 windows — if previously tiled, center the remaining one
  if echo "$PREV_STATE" | grep -q "^tiled"; then
    rm -f "$STATE_FILE"
    exec "$HOME/.config/aerospace/sketchybar/plugins/dynamic_gaps.sh"
  fi
fi
