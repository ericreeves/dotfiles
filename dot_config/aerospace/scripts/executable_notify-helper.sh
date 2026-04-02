#!/bin/bash
# Send an event to the aerospace-helper daemon via Unix socket
echo "$1" | nc -U /tmp/aerospace-helper.sock 2>/dev/null &
