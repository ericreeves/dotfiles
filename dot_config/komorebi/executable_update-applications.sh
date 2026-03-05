#!/usr/bin/env bash
set -euo pipefail

custom_json_path="${1:-$KOMOREBI_CONFIG_HOME/applications-custom.json}"
upstream_json_path="${2:-$KOMOREBI_CONFIG_HOME/applications-upstream.json}"
merged_json_path="${3:-$KOMOREBI_CONFIG_HOME/applications.json}"
komorebi_config_path="${4:-$KOMOREBI_CONFIG_HOME/komorebi.json}"

success=true

# Check if files exist
if [[ ! -f "$custom_json_path" ]]; then
    echo "Error: Custom JSON file not found: $custom_json_path" >&2
    exit 1
fi

# Generate and update schema file
echo "Generating komorebi configuration schema..."
schema_path="$KOMOREBI_CONFIG_HOME/schema.json"
if schema_output=$(komorebic static-config-schema 2>&1); then
    echo "$schema_output" > "$schema_path"
    echo "Successfully updated schema.json"
else
    echo "Warning: Failed to generate schema" >&2
    success=false
fi

# Fetch latest application configuration from GitHub
echo "Fetching latest application configuration from GitHub..."
if komorebic fetch-app-specific-configuration; then
    echo "Successfully updated applications.json from GitHub"

    # Rename applications.json to applications-upstream.json
    applications_json_path="$KOMOREBI_CONFIG_HOME/applications.json"
    if [[ -f "$applications_json_path" ]]; then
        mv -f "$applications_json_path" "$upstream_json_path"
        echo "Renamed applications.json to applications-upstream.json"
    fi
else
    echo "Error: Failed to fetch application configuration from GitHub" >&2
    success=false
fi

# Merge JSON files: upstream as base, custom overrides, $schema forced first
jq -s '
    .[0] * .[1]
    | {"$schema": "https://raw.githubusercontent.com/LGUG2Z/komorebi/master/schema.asc.json"}
      + (del(."$schema"))
' "$upstream_json_path" "$custom_json_path" > "$merged_json_path"

echo "Merged JSON written to $merged_json_path"

# Update komorebi.json if needed
if [[ -f "$komorebi_config_path" ]]; then
    echo "Checking komorebi.json configuration..."

    current_type=$(jq -r '.app_specific_configuration_path | type' "$komorebi_config_path")

    if [[ "$current_type" == "null" ]]; then
        echo "app_specific_configuration_path not found, adding it..."
        needs_update=true
    elif [[ "$current_type" == "array" ]]; then
        count=$(jq '.app_specific_configuration_path | length' "$komorebi_config_path")
        first=$(jq -r '.app_specific_configuration_path[0]' "$komorebi_config_path")
        if [[ "$count" -ne 1 || "$first" != "$merged_json_path" ]]; then
            echo "app_specific_configuration_path has incorrect value(s), updating..."
            needs_update=true
        else
            needs_update=false
        fi
    else
        current_value=$(jq -r '.app_specific_configuration_path' "$komorebi_config_path")
        if [[ "$current_value" != "$merged_json_path" ]]; then
            echo "app_specific_configuration_path has incorrect value, updating..."
            needs_update=true
        else
            needs_update=false
        fi
    fi

    if [[ "$needs_update" == true ]]; then
        jq --arg path "$merged_json_path" '.app_specific_configuration_path = [$path]' \
            "$komorebi_config_path" > "$komorebi_config_path.tmp" \
            && mv "$komorebi_config_path.tmp" "$komorebi_config_path"
        echo "Updated komorebi.json with correct app_specific_configuration_path"
    else
        echo "komorebi.json already has correct app_specific_configuration_path"
    fi
else
    echo "Warning: komorebi.json not found at $komorebi_config_path" >&2
fi

if [[ "$success" == true ]]; then
    echo "Replacing komorebi configuration..."
    if komorebic replace-configuration "$komorebi_config_path"; then
        echo "Successfully replaced komorebi configuration"
    else
        echo "Error: Failed to reload configuration" >&2
    fi
else
    echo "Warning: Skipping configuration reload due to previous errors" >&2
fi
