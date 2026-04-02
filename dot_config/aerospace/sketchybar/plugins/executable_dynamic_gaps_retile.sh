#!/bin/bash

# Focus-change handler for dynamic gaps.
# Detects window count changes and delegates to full script when needed:
#   - Was centered, now 2+ windows → retile all
#   - Was tiled/empty, now 1 window → delegate to dynamic_gaps.sh to center
#   - No state + 1 window (new app launched) → delegate to center

STATE_DIR="/tmp/aerospace_dynamic_gaps"

WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
[ -z "$WORKSPACE" ] && exit 0

# On non-G9 workspaces, ensure no windows are stuck floating from centering
MONITOR=$(aerospace list-windows --workspace "$WORKSPACE" --format '%{monitor-name}' 2>/dev/null | head -1)
case "$MONITOR" in
  *Odyssey*|*G95*) ;; # G9 — continue with centering logic
  *)
    # Not G9 — retile any floating windows that arrived from centering
    for wid in $(aerospace list-windows --workspace "$WORKSPACE" --format '%{window-id}' 2>/dev/null); do
      aerospace layout --window-id "$wid" tiling 2>/dev/null || true
    done
    rm -f "$STATE_DIR/ws_${WORKSPACE}"
    exit 0
    ;;
esac

STATE_FILE="$STATE_DIR/ws_${WORKSPACE}"
PREV_STATE=$(cat "$STATE_FILE" 2>/dev/null)

# Quick window count
COUNT=$(aerospace list-windows --workspace "$WORKSPACE" --count 2>/dev/null)

if [ "${COUNT:-0}" -ge 2 ]; then
  # 2+ windows — retile if we were centered
  if echo "$PREV_STATE" | grep -q "^centered"; then
    for wid in $(aerospace list-windows --workspace "$WORKSPACE" --format '%{window-id}' 2>/dev/null); do
      aerospace layout --window-id "$wid" tiling 2>/dev/null || true
    done
    echo "tiled $COUNT" > "$STATE_FILE"
  fi

elif [ "${COUNT:-0}" -eq 1 ]; then
  # 1 window — center if not already centered
  if ! echo "$PREV_STATE" | grep -q "^centered"; then
    # Trigger sketchybar update for workspace icons
    sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$WORKSPACE" 2>/dev/null
    exec "$HOME/.config/aerospace/sketchybar/plugins/dynamic_gaps.sh"
  fi

elif [ "${COUNT:-0}" -eq 0 ]; then
  rm -f "$STATE_FILE"
fi
