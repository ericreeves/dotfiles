# Sync Servy services with JSON configuration files
Import-Module "C:\Program Files\Servy\Servy.psm1" -ErrorAction Stop

$servyConfigPath = Join-Path $env:USERPROFILE ".config\servy"

# Check if the directory exists
if (-not (Test-Path $servyConfigPath)) {
    Write-Host "Error: Servy config directory not found at $servyConfigPath" -ForegroundColor Red
    exit 1
}

# Get all JSON files and extract service names
$jsonFiles = Get-ChildItem -Path $servyConfigPath -Filter "*.json" -File
$configuredServices = @{}

Write-Host "Reading service configurations..." -ForegroundColor Cyan

foreach ($file in $jsonFiles) {
    try {
        $config = Get-Content $file.FullName -Raw | ConvertFrom-Json
        if ($config.Name) {
            $configuredServices[$config.Name] = $file.FullName
            Write-Host "  Found: $($config.Name) ($($file.Name))" -ForegroundColor Gray
        } else {
            Write-Host "  Warning: $($file.Name) has no Name field" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  Error reading $($file.Name): $_" -ForegroundColor Red
    }
}

if ($configuredServices.Count -eq 0) {
    Write-Host "No valid service configurations found" -ForegroundColor Yellow
    exit 0
}

Write-Host "`nConfigured services count: $($configuredServices.Count)" -ForegroundColor Green

# Import/update all configured services
Write-Host "`nImporting service configurations..." -ForegroundColor Cyan

foreach ($serviceName in $configuredServices.Keys) {
    $configFile = $configuredServices[$serviceName]
    Write-Host "`nImporting: $serviceName" -ForegroundColor Cyan

    try {
        Import-ServyServiceConfig -ConfigFileType "json" -Path $configFile -Quiet
        Write-Host "  Successfully imported: $serviceName" -ForegroundColor Green
    } catch {
        Write-Host "  Error importing $serviceName : $_" -ForegroundColor Red
    }
}

# Optional: Clean up services not in config directory
# NOTE: This requires manual maintenance of a tracking file since servy-cli has no 'list' command
$trackingFile = Join-Path $servyConfigPath ".servy-tracking.json"

if (Test-Path $trackingFile) {
    Write-Host "`nChecking for services to remove..." -ForegroundColor Cyan

    try {
        $previousServices = Get-Content $trackingFile -Raw | ConvertFrom-Json

        foreach ($oldService in $previousServices) {
            if (-not $configuredServices.ContainsKey($oldService)) {
                Write-Host "`nRemoving service no longer in config: $oldService" -ForegroundColor Yellow

                try {
                    Uninstall-ServyService -Name $oldService -Quiet
                    Write-Host "  Successfully uninstalled: $oldService" -ForegroundColor Green
                } catch {
                    Write-Host "  Error uninstalling $oldService : $_" -ForegroundColor Red
                }
            }
        }
    } catch {
        Write-Host "  Error reading tracking file: $_" -ForegroundColor Red
    }
}

# Update tracking file with current services
$configuredServices.Keys | ConvertTo-Json | Set-Content $trackingFile
Write-Host "`nTracking file updated: $trackingFile" -ForegroundColor Gray

Write-Host "`nSync process completed." -ForegroundColor Green
