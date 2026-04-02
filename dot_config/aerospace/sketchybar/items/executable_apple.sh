#!/bin/bash

sketchybar --add item apple left \
  --set apple \
    icon="$ICON_APPLE" \
    icon.font="$NERD_FONT:Bold:18.0" \
    icon.color=$GREEN \
    icon.padding_left=8 \
    icon.padding_right=8 \
    label.drawing=off \
    background.drawing=off \
    click_script="sketchybar --set apple popup.drawing=toggle" \
    popup.background.color=$HIGHLIGHT \
    popup.background.corner_radius=9 \
    popup.background.border_width=2 \
    popup.background.border_color=$BAR_BORDER_COLOR

# Popup items
sketchybar --add item apple.settings popup.apple \
  --set apple.settings \
    icon="󰒓" \
    icon.font="$NERD_FONT:Bold:14.0" \
    label="Settings" \
    click_script="open -a 'System Settings'; sketchybar --set apple popup.drawing=off"

sketchybar --add item apple.activity popup.apple \
  --set apple.activity \
    icon="󱕍" \
    icon.font="$NERD_FONT:Bold:14.0" \
    label="Activity Monitor" \
    click_script="open -a 'Activity Monitor'; sketchybar --set apple popup.drawing=off"

sketchybar --add item apple.lock popup.apple \
  --set apple.lock \
    icon="󰌾" \
    icon.font="$NERD_FONT:Bold:14.0" \
    label="Lock Screen" \
    click_script="pmset displaysleepnow; sketchybar --set apple popup.drawing=off"

sketchybar --add item apple.restart popup.apple \
  --set apple.restart \
    icon="󰜉" \
    icon.font="$NERD_FONT:Bold:14.0" \
    label="Restart" \
    label.color=$RED \
    click_script="osascript -e 'tell app \"System Events\" to restart'; sketchybar --set apple popup.drawing=off"
