#!/bin/bash

INTERFACE=$(route get default 2>/dev/null | awk '/interface/{print $2}')
if [ -n "$INTERFACE" ]; then
  STATS=$(netstat -ib -I "$INTERFACE" 2>/dev/null | awk 'NR==2{print $7, $10}')
  IN=$(echo "$STATS" | awk '{printf "%.1f", $1/1024/1024}')
  OUT=$(echo "$STATS" | awk '{printf "%.1f", $2/1024/1024}')
  sketchybar --set "$NAME" label="${IN}/${OUT} MB"
else
  sketchybar --set "$NAME" label="--"
fi
