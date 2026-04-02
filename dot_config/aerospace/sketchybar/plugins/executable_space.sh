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
    background.color=0xff313244
else
  sketchybar --set "$NAME" \
    icon.highlight=off \
    label.highlight=off \
    background.color=0x00000000
fi

# Build app icon string — exclude hidden apps and always-floating apps
HIDDEN_BIDS=$(osascript -e '
tell application "System Events"
  set output to ""
  repeat with p in (every application process whose background only is false and visible is false)
    set output to output & bundle identifier of p & linefeed
  end repeat
  return output
end tell' 2>/dev/null)

# Always-floating apps (from aerospace on-window-detected rules)
FLOATING_BIDS="com.mantle.app com.1password.1password com.microsoft.teams2 com.wispr.flow com.logi.cp-dev-mgr.common com.apple.ScreenMirroring com.anthropic.claudefordesktop com.cisco.secureclient.gui com.elgato.StreamDeck us.zoom.xos"

APPS=$(aerospace list-windows --workspace "$SID" --format '%{app-name}|%{app-bundle-id}' 2>/dev/null)
ICON_STRIP=""

if [ -n "$APPS" ]; then
  while IFS='|' read -r app bid; do
    [ -z "$app" ] && continue
    if [ -n "$HIDDEN_BIDS" ] && echo "$HIDDEN_BIDS" | grep -qx "$bid"; then
      continue
    fi
    if echo "$FLOATING_BIDS" | grep -qw "$bid"; then
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
