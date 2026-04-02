#!/bin/bash

# Auto-center single window on G9 ultrawide (5120x1440)
# Only activates on the Odyssey G95SC monitor
# 1 visible window: float and center at 2560px
# 2+ visible windows: retile all
# State tracked per workspace to avoid redundant repositioning

G9_WIDTH=5120
CENTER_W=2560
TOP_Y=85
BOTTOM_PAD=15
STATE_DIR="/tmp/aerospace_dynamic_gaps"
mkdir -p "$STATE_DIR"

WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
[ -z "$WORKSPACE" ] && exit 0

# Only apply on G9 workspaces (check monitor)
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

# Get hidden app bundle IDs (synchronous — waits for result)
HIDDEN_BIDS=$(osascript -e '
tell application "System Events"
  set output to ""
  repeat with p in (every application process whose background only is false and visible is false)
    set output to output & bundle identifier of p & linefeed
  end repeat
  return output
end tell' 2>/dev/null)

# Count visible windows (exclude hidden apps by bundle ID)
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

  # Already centered with same window — skip
  [ "$PREV_STATE" = "centered $WID" ] && exit 0

  # Float and center — brief delay to let window settle after workspace move
  sleep 0.2
  aerospace layout --window-id "$WID" floating 2>/dev/null
  sleep 0.1

  H=$((1440 - TOP_Y - BOTTOM_PAD))
  X=$(( (G9_WIDTH - CENTER_W) / 2 ))

  # Get the app name for this specific window
  APP_NAME=$(aerospace list-windows --format '%{window-id}|%{app-name}' --workspace "$WORKSPACE" 2>/dev/null | grep "^${WID}|" | cut -d'|' -f2)

  osascript -e "
  tell application \"System Events\"
    tell application process \"$APP_NAME\"
      try
        set position of front window to {$X, $TOP_Y}
        set size of front window to {$CENTER_W, $H}
      end try
    end tell
  end tell
  " 2>/dev/null

  echo "centered $WID" > "$STATE_FILE"

elif [ "$COUNT" -ge 2 ]; then
  # Only retile if previously centered
  if echo "$PREV_STATE" | grep -q "^centered"; then
    for wid in "${VISIBLE_WIDS[@]}"; do
      aerospace layout --window-id "$wid" tiling 2>/dev/null || true
    done
  fi
  echo "tiled $COUNT" > "$STATE_FILE"

else
  rm -f "$STATE_FILE"
fi
