#!/bin/bash

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9")

for i in "${!SPACE_ICONS[@]}"; do
  sid="${SPACE_ICONS[$i]}"
  sketchybar --add item space.$sid center \
    --set space.$sid \
      icon="$sid" \
      icon.font="$FONT:Bold:12.0" \
      icon.color=$SUBTLE \
      icon.highlight_color=$ACCENT_COLOR \
      icon.padding_left=6 \
      icon.padding_right=2 \
      label.font="sketchybar-app-font:Regular:14.0" \
      label.color=$SUBTLE \
      label.highlight_color=$ACCENT_COLOR \
      label.padding_left=2 \
      label.padding_right=6 \
      label.y_offset=1 \
      background.drawing=on \
      background.color=$TRANSPARENT \
      background.corner_radius=5 \
      background.height=26 \
      click_script="aerospace workspace $sid" \
      script="$PLUGIN_DIR/space.sh" \
    --subscribe space.$sid aerospace_workspace_change
done
