#!/bin/bash

# Position focused window on G9 ultrawide (5120x1440)
# Usage: window_position.sh [left|center|right]
# Floats the window and snaps it to the specified position

POSITION="${1:-center}"
G9_WIDTH=5120
PANE_W=2530
TOP_Y=50
BOTTOM_PAD=15

# Get focused window ID
WINDOW_ID=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
[ -z "$WINDOW_ID" ] && exit 1

# Float the window
aerospace layout --window-id "$WINDOW_ID" floating 2>/dev/null

H=$((1440 - TOP_Y - BOTTOM_PAD))

case "$POSITION" in
  left)
    X=15
    ;;
  center)
    X=$(( (G9_WIDTH - PANE_W) / 2 ))
    ;;
  right)
    X=$((G9_WIDTH - PANE_W - 15))
    ;;
  *) exit 1 ;;
esac

osascript -e "
tell application \"System Events\"
  set frontApp to name of first application process whose frontmost is true
  tell application process frontApp
    try
      set position of front window to {$X, $TOP_Y}
      set size of front window to {$PANE_W, $H}
    end try
  end tell
end tell
" 2>/dev/null
