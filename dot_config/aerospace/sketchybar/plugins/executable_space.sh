#!/bin/bash

source "$CONFIG_DIR/icon_map.sh"

SID="${NAME##*.}"

# Determine which workspaces belong to each monitor
MONITORS=$(aerospace list-monitors --format '%{monitor-id}' 2>/dev/null)
MONITOR_COUNT=$(echo "$MONITORS" | wc -l | tr -d ' ')

# Get workspaces for the monitor this bar instance is on
# sketchybar runs one bar per display — $DISPLAY tracks which one
# We check if this workspace is assigned to the focused monitor's set
MY_WORKSPACES=$(aerospace list-workspaces --monitor all --format '%{workspace}|%{monitor-id}' 2>/dev/null)

# For each space item, show only if it belongs to the display showing this bar
# Workspace-to-monitor: 1-5 = monitor 1 (main/G9), 6-9 = monitor 2 (MBP)
WORKSPACE_MONITOR=$(echo "$MY_WORKSPACES" | grep "^${SID}|" | cut -d'|' -f2)

# If only one monitor, show all workspaces
if [ "$MONITOR_COUNT" -le 1 ]; then
  SHOW="true"
else
  # Show workspace only on its assigned monitor's bar
  # associated_display filters which bar shows this item
  # We set display association based on monitor ID
  if [ "$WORKSPACE_MONITOR" = "1" ]; then
    sketchybar --set "$NAME" associated_display=1
  elif [ "$WORKSPACE_MONITOR" = "2" ]; then
    sketchybar --set "$NAME" associated_display=2
  fi
fi

# Highlight focused workspace
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" \
      icon.highlight=on \
      label.highlight=on \
      background.color=0xff2c2c2e
  else
    sketchybar --set "$NAME" \
      icon.highlight=off \
      label.highlight=off \
      background.color=0x00000000
  fi
fi

# Get hidden app bundle IDs
HIDDEN_BIDS=$(osascript -e '
tell application "System Events"
  set output to ""
  repeat with p in (every application process whose background only is false and visible is false)
    set output to output & bundle identifier of p & linefeed
  end repeat
  return output
end tell' 2>/dev/null)

# Build app icon string for this workspace, skipping hidden apps
APPS=$(aerospace list-windows --workspace "$SID" --format '%{app-name}|%{app-bundle-id}' 2>/dev/null)
ICON_STRIP=""

if [ -n "$APPS" ]; then
  while IFS='|' read -r app bid; do
    [ -z "$app" ] && continue
    # Skip hidden apps
    if echo "$HIDDEN_BIDS" | grep -qx "$bid"; then
      continue
    fi
    __icon_map "$app"
    ICON_STRIP+="${icon_result} "
  done <<< "$APPS"
fi

ICON_STRIP="${ICON_STRIP% }"

if [ -n "$ICON_STRIP" ]; then
  sketchybar --set "$NAME" label="$ICON_STRIP"
else
  sketchybar --set "$NAME" label=""
fi
