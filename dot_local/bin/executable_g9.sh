#!/bin/bash
G9_DEVICE_ID="bc65832c-a988-4f02-3ccc-a1669e269682"

case "$1" in
  hdmi1)
    smartthings devices:commands $G9_DEVICE_ID 'samsungvd.mediaInputSource:setInputSource("HDMI1")'
    ;;
  dp1)
    smartthings devices:commands $G9_DEVICE_ID 'samsungvd.mediaInputSource:setInputSource("Display Port")'
    ;;
  *)
    echo "Usage: g9.sh <hdmi1|dp1>"
    echo "  hdmi1  - Switch to HDMI 1"
    echo "  dp1    - Switch to DisplayPort"
    exit 1
    ;;
esac
