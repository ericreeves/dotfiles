#!/usr/bin/env bash
set -euo pipefail

export KOMOREBI_CONFIG_HOME="$HOME/.config/komorebi"

# Fetch latest application configuration from GitHub
echo "Fetching latest application configuration from GitHub..."
if komorebic fetch-app-specific-configuration; then
  echo "Successfully downloaded applications.json from GitHub"
else
  echo "Error: Failed to fetch application configuration from GitHub" >&2
  exit 1
fi
