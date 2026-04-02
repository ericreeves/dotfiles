#!/bin/bash

source "$CONFIG_DIR/icon_map.sh"

SID="${NAME##*.}"

# Assign workspace to its monitor's display (multi-monitor: show only relevant workspaces per bar)
MONITOR_COUNT=$(aerospace list-monitors --count 2>/dev/null)
if [ "${MONITOR_COUNT:-1}" -gt 1 ]; then
  WS_MONITOR=$(aerospace list-workspaces --monitor all --format '%{workspace}|%{monitor-id}' 2>/dev/null | grep "^${SID}|" | cut -d'|' -f2)
  if [ -n "$WS_MONITOR" ]; then
    sketchybar --set "$NAME" associated_display="$WS_MONITOR"
  fi
fi

# Highlight focused workspace
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

# Build app icon string — only visible (non-hidden) apps
HIDDEN_BIDS=$(osascript -e '
tell application "System Events"
  set output to ""
  repeat with p in (every application process whose background only is false and visible is false)
    set output to output & bundle identifier of p & linefeed
  end repeat
  return output
end tell' 2>/dev/null)

APPS=$(aerospace list-windows --workspace "$SID" --format '%{app-name}|%{app-bundle-id}' 2>/dev/null)
ICON_STRIP=""

if [ -n "$APPS" ]; then
  while IFS='|' read -r app bid; do
    [ -z "$app" ] && continue
    if [ -n "$HIDDEN_BIDS" ] && echo "$HIDDEN_BIDS" | grep -qx "$bid"; then
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
