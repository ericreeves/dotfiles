#!/bin/bash

MEM=$(memory_pressure 2>/dev/null | awk '/percentage/{gsub(/%/,""); printf "%.0f%%", 100 - $NF}')
if [ -z "$MEM" ]; then
  # Fallback: parse vm_stat
  PAGES_FREE=$(vm_stat | awk '/Pages free/{gsub(/\./,""); print $3}')
  PAGES_ACTIVE=$(vm_stat | awk '/Pages active/{gsub(/\./,""); print $3}')
  PAGES_INACTIVE=$(vm_stat | awk '/Pages inactive/{gsub(/\./,""); print $3}')
  PAGES_WIRED=$(vm_stat | awk '/Pages wired/{gsub(/\./,""); print $4}')
  TOTAL=$((PAGES_FREE + PAGES_ACTIVE + PAGES_INACTIVE + PAGES_WIRED))
  USED=$((PAGES_ACTIVE + PAGES_WIRED))
  if [ "$TOTAL" -gt 0 ] 2>/dev/null; then
    MEM="$((USED * 100 / TOTAL))%"
  else
    MEM="?"
  fi
fi
sketchybar --set "$NAME" label="$MEM"
