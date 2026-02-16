param (
    [Parameter(Mandatory=$false)]
    [string]$customJsonPath = "$Env:KOMOREBI_CONFIG_HOME/applications-custom.json",

    [Parameter(Mandatory=$false)]
    [string]$upstreamJsonPath = "$Env:KOMOREBI_CONFIG_HOME/applications-upstream.json",

    [Parameter(Mandatory=$false)]
    [string]$mergedJsonPath = "$Env:KOMOREBI_CONFIG_HOME/applications.json",

    [Parameter(Mandatory=$false)]
    [string]$komorebiConfigPath = "$Env:KOMOREBI_CONFIG_HOME/komorebi.json"
)

$success = $true

# Check if files exist
if (-not (Test-Path $customJsonPath)) {
    Write-Error "Custom JSON file not found: $customJsonPath"
    exit 1
}

# Generate and update schema file
Write-Host "Generating komorebi configuration schema..."
try {
    $schemaOutput = & komorebic static-config-schema
    if ($LASTEXITCODE -eq 0) {
        $schemaPath = "$Env:KOMOREBI_CONFIG_HOME/schema.json"
        Set-Content -Path $schemaPath -Value $schemaOutput
        Write-Host "Successfully updated schema.json"
    } else {
        Write-Warning "Failed to generate schema, exit code: $LASTEXITCODE"
        $success = $false
    }
} catch {
    Write-Warning "Error running komorebic static-config-schema: $_"
}

# Fetch latest application configuration from GitHub
Write-Host "Fetching latest application configuration from GitHub..."
try {
    & komorebic fetch-app-specific-configuration
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to fetch application configuration from GitHub"
        $success = $false
    }
    Write-Host "Successfully updated applications.json from GitHub"

    # Rename applications.json to applications-upstream.json
    $applicationsJsonPath = "$Env:KOMOREBI_CONFIG_HOME/applications.json"
    $upstreamJsonPath = "$Env:KOMOREBI_CONFIG_HOME/applications-upstream.json"
    if (Test-Path $applicationsJsonPath) {
        Move-Item -Path $applicationsJsonPath -Destination $upstreamJsonPath -Force
        Write-Host "Renamed applications.json to applications-upstream.json"
    }
} catch {
    Write-Error "Error running komorebic fetch-app-specific-configuration: $_"
    $success = $false
}
# Read and convert JSON files to hashtables
$first  = Get-Content $customJsonPath -Raw | ConvertFrom-Json -AsHashtable
$second = Get-Content $upstreamJsonPath -Raw | ConvertFrom-Json -AsHashtable

# Create a new hashtable for the merged result
# Use [ordered] to maintain insertion order
$merged = [ordered]@{}

# Add $schema as the first entry
$merged['$schema'] = "https://raw.githubusercontent.com/LGUG2Z/komorebi/master/schema.asc.json"

# Add all keys from the second file first
foreach ($key in $second.Keys) {
    if ($key -ne '$schema') {
        $merged[$key] = $second[$key]
    }
}

# Overwrite/add all keys from the first file (no recursion)
foreach ($key in $first.Keys) {
    if ($key -ne '$schema') {
        $merged[$key] = $first[$key]
    }
}

# Convert to JSON string
$json = $merged | ConvertTo-Json -Depth 100

# Write to output file
Set-Content -Path $mergedJsonPath -Value $json

Write-Host "Merged JSON written to $mergedJsonPath"

if (Test-Path $komorebiConfigPath) {
    Write-Host "Checking komorebi.json configuration..."

    try {
        # Read komorebi.json
        $komorebiConfigContent = Get-Content $komorebiConfigPath -Raw
        $komorebiConfigJson = $komorebiConfigContent | ConvertFrom-Json

        # Check if app_specific_configuration_path exists and is correct
        $needsUpdate = $false

        if (-not $komorebiConfigJson.app_specific_configuration_path) {
            Write-Host "app_specific_configuration_path not found, adding it..."
            $needsUpdate = $true
        } elseif ($komorebiConfigJson.app_specific_configuration_path -is [array]) {
            if ($komorebiConfigJson.app_specific_configuration_path.Count -ne 1 -or
                $komorebiConfigJson.app_specific_configuration_path[0] -ne $mergedJsonPath) {
                Write-Host "app_specific_configuration_path has incorrect value(s), updating..."
                $needsUpdate = $true
            }
        } else {
            if ($komorebiConfigJson.app_specific_configuration_path -ne $mergedJsonPath) {
                Write-Host "app_specific_configuration_path has incorrect value, updating..."
                $needsUpdate = $true
            }
        }

        if ($needsUpdate) {
            # Update the configuration
            $komorebiConfigJson.app_specific_configuration_path = @($mergedJsonPath)

            # Convert back to JSON and write
            $updatedJson = $komorebiConfigJson | ConvertTo-Json -Depth 100
            Set-Content -Path $komorebiConfigPath -Value $updatedJson

            Write-Host "Updated komorebi.json with correct app_specific_configuration_path"
        } else {
            Write-Host "komorebi.json already has correct app_specific_configuration_path"
        }

    } catch {
        Write-Warning "Failed to update komorebi.json: $_"
        $success = $false
    }
} else {
    Write-Warning "komorebi.json not found at $komorebiConfigPath"
}

if ($success) {
    Write-Host "Reloading komorebi configuration..."
    & komorebic reload-configuration
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to reload configuration"
    } else {
        Write-Host "Successfully reloaded komorebi configuration"
    }
} else {
    Write-Warning "Skipping configuration reload due to previous errors"
}
