param (
    [Parameter(Mandatory=$false)]
    [string]$CustomJsonFile = "$Env:KOMOREBI_CONFIG_HOME/applications-custom.json",

    [Parameter(Mandatory=$false)]
    [string]$StockJsonFile = "$Env:KOMOREBI_CONFIG_HOME/applications.json",

    [Parameter(Mandatory=$false)]
    [string]$MergedJson = "$Env:KOMOREBI_CONFIG_HOME/applications-merged.json"
)

# Check if files exist
if (-not (Test-Path $CustomJsonFile)) {
    Write-Error "Custom JSON file not found: $CustomJsonFile"
    exit 1
}

if (-not (Test-Path $StockJsonFile)) {
    Write-Error "Stock JSON file not found: $StockJsonFile"
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
    }
    Write-Host "Successfully updated applications.json from GitHub"
} catch {
    Write-Error "Error running komorebic fetch-app-specific-configuration: $_"
}

# Read and convert JSON files to hashtables
$first  = Get-Content $CustomJsonFile -Raw | ConvertFrom-Json -AsHashtable
$second = Get-Content $StockJsonFile -Raw | ConvertFrom-Json -AsHashtable

# Create a new hashtable for the merged result
$merged = @{}

# Add all keys from the second file first
foreach ($key in $second.Keys) {
    $merged[$key] = $second[$key]
}

# Overwrite/add all keys from the first file (no recursion)
foreach ($key in $first.Keys) {
    $merged[$key] = $first[$key]
}

# Convert to JSON string
$json = $merged | ConvertTo-Json -Depth 100

# Write to output file
Set-Content -Path $MergedJson -Value $json

Write-Host "Merged JSON written to $MergedJson"

# Check and update komorebi.json to ensure app_specific_configuration_path is correct
$komorebiconfigPath = "$Env:KOMOREBI_CONFIG_HOME/komorebi.json"
$expectedPath = "`$Env:KOMOREBI_CONFIG_HOME/applications-merged.json"

if (Test-Path $komorebiconfigPath) {
    Write-Host "Checking komorebi.json configuration..."
    
    try {
        # Read komorebi.json
        $komorebiconfigContent = Get-Content $komorebiconfigPath -Raw
        $komorebiconfigJson = $komorebiconfigContent | ConvertFrom-Json
        
        # Check if app_specific_configuration_path exists and is correct
        $needsUpdate = $false
        
        if (-not $komorebiconfigJson.app_specific_configuration_path) {
            Write-Host "app_specific_configuration_path not found, adding it..."
            $needsUpdate = $true
        } elseif ($komorebiconfigJson.app_specific_configuration_path -is [array]) {
            if ($komorebiconfigJson.app_specific_configuration_path.Count -ne 1 -or 
                $komorebiconfigJson.app_specific_configuration_path[0] -ne $expectedPath) {
                Write-Host "app_specific_configuration_path has incorrect value(s), updating..."
                $needsUpdate = $true
            }
        } else {
            if ($komorebiconfigJson.app_specific_configuration_path -ne $expectedPath) {
                Write-Host "app_specific_configuration_path has incorrect value, updating..."
                $needsUpdate = $true
            }
        }
        
        if ($needsUpdate) {
            # Update the configuration
            $komorebiconfigJson.app_specific_configuration_path = @($expectedPath)
            
            # Convert back to JSON and write
            $updatedJson = $komorebiconfigJson | ConvertTo-Json -Depth 100
            Set-Content -Path $komorebiconfigPath -Value $updatedJson
            
            Write-Host "Updated komorebi.json with correct app_specific_configuration_path"
        } else {
            Write-Host "komorebi.json already has correct app_specific_configuration_path"
        }
        
    } catch {
        Write-Warning "Failed to update komorebi.json: $_"
    }
} else {
    Write-Warning "komorebi.json not found at $komorebiconfigPath"
}

