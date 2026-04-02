#!/bin/bash

# Auto-center single window on G9 ultrawide (5120x1440)
# Only activates on the Odyssey G95SC monitor
# 1 visible window: float and center at 2560px wide
# 2+ visible windows: retile all

G9_WIDTH=5120
CENTER_W=2560
TOP_Y=85
BOTTOM_PAD=15
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

  # Tile first (resets floating position), then float, then position via osascript
  aerospace layout --window-id "$WID" tiling 2>/dev/null
  aerospace layout --window-id "$WID" floating 2>/dev/null

  H=$((1440 - TOP_Y - BOTTOM_PAD))
  X=$(( (G9_WIDTH - CENTER_W) / 2 ))
  APP_NAME=$(aerospace list-windows --format '%{window-id}|%{app-name}' --workspace "$WORKSPACE" 2>/dev/null | grep "^${WID}|" | cut -d'|' -f2)

  osascript -e "
  tell application \"System Events\"
    tell application process \"$APP_NAME\"
      set position of front window to {$X, $TOP_Y}
      set size of front window to {$CENTER_W, $H}
    end tell
  end tell" 2>/dev/null

  # Verify position was set correctly
  ACTUAL_X=$(osascript -e "tell application \"System Events\" to tell application process \"$APP_NAME\" to get item 1 of (get position of front window)" 2>/dev/null)
  if [ "$ACTUAL_X" = "$X" ]; then
    echo "centered $WID" > "$STATE_FILE"
  else
    # Position failed — retile and don't mark as centered
    aerospace layout --window-id "$WID" tiling 2>/dev/null
    echo "tiled 1" > "$STATE_FILE"
  fi

elif [ "$COUNT" -ge 2 ]; then
  if echo "$PREV_STATE" | grep -q "^centered"; then
    # Only retile the window that was auto-centered, not user-floated windows
    AUTO_WID=$(echo "$PREV_STATE" | awk '{print $2}')
    aerospace layout --window-id "$AUTO_WID" tiling 2>/dev/null || true
    # Also tile the new arrival (it's likely tiling already, but be safe)
    for wid in "${VISIBLE_WIDS[@]}"; do
      [ "$wid" = "$AUTO_WID" ] && continue
      aerospace layout --window-id "$wid" tiling 2>/dev/null || true
    done
  fi
  echo "tiled $COUNT" > "$STATE_FILE"

else
  rm -f "$STATE_FILE"
fi
