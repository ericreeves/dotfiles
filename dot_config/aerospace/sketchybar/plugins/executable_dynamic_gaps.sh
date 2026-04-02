#!/bin/bash

# Auto-center single window on G9 ultrawide (5120x1440)
# Only activates on the Odyssey G95SC monitor
# 1 visible window: float and center at 2560px
# 2+ visible windows: retile all
#
# Positioning: float the window, then use aerospace resize to shrink it.
# Aerospace places floating windows centered on the monitor by default.

STATE_DIR="/tmp/aerospace_dynamic_gaps"
mkdir -p "$STATE_DIR"

WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
[ -z "$WORKSPACE" ] && exit 0

# Only apply on G9
MONITOR=$(aerospace list-windows --workspace "$WORKSPACE" --format '%{monitor-name}' 2>/dev/null | head -1)
if [ -z "$MONITOR" ]; then
  for mid in $(aerospace list-monitors --format '%{monitor-id}' 2>/dev/null); do
    if aerospace list-workspaces --monitor "$mid" --format '%{workspace}' 2>/dev/null | grep -qx "$WORKSPACE"; then
      MONITOR=$(aerospace list-monitors --format '%{monitor-id}|%{monitor-name}' 2>/dev/null | grep "^${mid}|" | cut -d'|' -f2)
      break
    fi
  done
fi

case "$MONITOR" in
  *Odyssey*|*G95*) ;;
  *) exit 0 ;;
esac

# Get hidden app bundle IDs
HIDDEN_BIDS=$(osascript -e '
tell application "System Events"
  set output to ""
  repeat with p in (every application process whose background only is false and visible is false)
    set output to output & bundle identifier of p & linefeed
  end repeat
  return output
end tell' 2>/dev/null)

# Count visible windows
VISIBLE_WIDS=()
while IFS='|' read -r wid bid; do
  [ -z "$wid" ] && continue
  if [ -n "$HIDDEN_BIDS" ] && echo "$HIDDEN_BIDS" | grep -qx "$bid"; then
    continue
  fi
  VISIBLE_WIDS+=("$wid")
done <<< "$(aerospace list-windows --workspace "$WORKSPACE" --format '%{window-id}|%{app-bundle-id}' 2>/dev/null)"

COUNT=${#VISIBLE_WIDS[@]}
STATE_FILE="$STATE_DIR/ws_${WORKSPACE}"
PREV_STATE=$(cat "$STATE_FILE" 2>/dev/null)

if [ "$COUNT" -eq 1 ]; then
  WID="${VISIBLE_WIDS[0]}"

  # Already centered — skip
  [ "$PREV_STATE" = "centered $WID" ] && exit 0

  # Float the window — aerospace places it centered on the monitor
  aerospace layout --window-id "$WID" floating 2>/dev/null

  # Resize to 2560px wide using absolute width
  # The window starts at full tiling size, so shrink it
  aerospace resize --window-id "$WID" width 2560 2>/dev/null
  aerospace resize --window-id "$WID" height 1340 2>/dev/null

  echo "centered $WID" > "$STATE_FILE"

elif [ "$COUNT" -ge 2 ]; then
  if echo "$PREV_STATE" | grep -q "^centered"; then
    for wid in "${VISIBLE_WIDS[@]}"; do
      aerospace layout --window-id "$wid" tiling 2>/dev/null || true
    done
  fi
  echo "tiled $COUNT" > "$STATE_FILE"

else
  rm -f "$STATE_FILE"
fi
