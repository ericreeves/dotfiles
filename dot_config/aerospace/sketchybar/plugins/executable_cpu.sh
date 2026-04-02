#!/bin/bash

CPU=$(top -l 1 -n 0 2>/dev/null | awk '/CPU usage/{printf "%.0f%%", $3}')
sketchybar --set "$NAME" label="${CPU:-?}"
