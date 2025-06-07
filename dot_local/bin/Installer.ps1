param(
    [Parameter(Mandatory=$false)]
    [string]$Path,
    
    [switch]$All
)

# Function to display usage information
function Show-Usage {
    param([string]$ScriptCommand)
    
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  $ScriptCommand -Path <directory_path> [-All]" -ForegroundColor White
    Write-Host ""
    Write-Host "PARAMETERS:" -ForegroundColor Yellow
    Write-Host "  -Path <string>    Required. The directory path to search for installers." -ForegroundColor White
    Write-Host "  -All              Optional. Run all found installers without prompting." -ForegroundColor White
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  $ScriptCommand -Path `"C:\Downloads`"" -ForegroundColor Gray
    Write-Host "  $ScriptCommand -Path `"C:\Software`" -All" -ForegroundColor Gray
    Write-Host ""
    Write-Host "INTERACTIVE USAGE:" -ForegroundColor Yellow
    Write-Host "  Enter '1' to run installer #1" -ForegroundColor Gray
    Write-Host "  Enter '1 3 5' to run installers #1, #3, and #5" -ForegroundColor Gray
    Write-Host "  Enter 'all' to run all installers" -ForegroundColor Gray
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Yellow
    Write-Host "  Searches for executable files (.exe, .msi, .bat, .cmd) containing 'install'" -ForegroundColor White
    Write-Host "  or 'setup' in their filename, then allows you to run them individually or all at once." -ForegroundColor White
    Write-Host ""
}

# Function to display colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [ConsoleColor]$ForegroundColor = [ConsoleColor]::White
    )
    Write-Host $Message -ForegroundColor $ForegroundColor
}

# Function to run an installer
function Invoke-Installer {
    param(
        [string]$InstallerPath,
        [int]$Index = 0,
        [int]$Total = 1
    )
    
    try {
        $fileName = Split-Path $InstallerPath -Leaf
        if ($Total -gt 1) {
            Write-ColorOutput "[$Index/$Total] Running installer: $fileName" -ForegroundColor Cyan
        } else {
            Write-ColorOutput "Running installer: $fileName" -ForegroundColor Cyan
        }
        
        # Start the installer process
        $process = Start-Process -FilePath $InstallerPath -Wait -PassThru -ErrorAction Stop
        
        if ($process.ExitCode -eq 0) {
            Write-ColorOutput "✓ Successfully completed: $fileName" -ForegroundColor Green
        } else {
            Write-ColorOutput "⚠ Installer finished with exit code $($process.ExitCode): $fileName" -ForegroundColor Yellow
        }
        
        return $true
    }
    catch {
        Write-ColorOutput "✗ Error running installer '$fileName': $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Get the command that was used to invoke this script
$scriptCommand = $MyInvocation.Line.Trim()
if (-not $scriptCommand) {
    # Fallback to script name if we can't get the full command line
    $scriptCommand = Split-Path $MyInvocation.ScriptName -Leaf
}

# Check if required parameters are provided
if (-not $Path -or $Path.Trim() -eq "") {
    Write-ColorOutput "Error: The -Path parameter is required." -ForegroundColor Red
    Show-Usage -ScriptCommand $scriptCommand
    exit 1
}

# Validate the path
if (-not (Test-Path $Path)) {
    Write-ColorOutput "Error: Path '$Path' does not exist." -ForegroundColor Red
    exit 1
}

Write-ColorOutput "Searching for installers in: $Path" -ForegroundColor Yellow

try {
    # Search for executable files with 'install' or 'setup' in the name
    $installers = Get-ChildItem -Path $Path -Recurse -File | 
        Where-Object { 
            $_.Extension -in @('.exe', '.msi', '.bat', '.cmd') -and 
            ($_.BaseName -match 'install|setup') 
        } | 
        Sort-Object Name
    
    if ($installers.Count -eq 0) {
        Write-ColorOutput "No installer files found in the specified path." -ForegroundColor Yellow
        exit 0
    }
    
    # Display found installers
    Write-ColorOutput "`nFound $($installers.Count) installer(s):" -ForegroundColor Green
    Write-Host ""
    
    for ($i = 0; $i -lt $installers.Count; $i++) {
        $installer = $installers[$i]
        $relativePath = $installer.FullName.Replace($Path, "").TrimStart('\', '/')
        Write-Host "  $($i + 1). $($installer.Name)" -ForegroundColor White
        Write-Host "     Path: $relativePath" -ForegroundColor Gray
    }
    
    # If -All switch is used, run all installers without prompting
    if ($All) {
        Write-ColorOutput "`n-All parameter specified. Running all installers..." -ForegroundColor Yellow
        $successCount = 0
        
        for ($i = 0; $i -lt $installers.Count; $i++) {
            if (Invoke-Installer -InstallerPath $installers[$i].FullName -Index ($i + 1) -Total $installers.Count) {
                $successCount++
            }
            
            # Add a small delay between installers
            if ($i -lt $installers.Count - 1) {
                Start-Sleep -Seconds 2
            }
        }
        
        Write-ColorOutput "`nCompleted: $successCount/$($installers.Count) installers ran successfully." -ForegroundColor Green
        exit 0
    }
    
    # Prompt user for selection
    Write-Host ""
    do {
        Write-Host "Enter installer number(s) (space-separated), or 'all' to run all installers: " -NoNewline -ForegroundColor Cyan
        $userInput = Read-Host
        
        if ($userInput.ToLower() -eq 'all') {
            Write-ColorOutput "`nRunning all installers..." -ForegroundColor Yellow
            $successCount = 0
            
            for ($i = 0; $i -lt $installers.Count; $i++) {
                if (Invoke-Installer -InstallerPath $installers[$i].FullName -Index ($i + 1) -Total $installers.Count) {
                    $successCount++
                }
                
                # Add a small delay between installers
                if ($i -lt $installers.Count - 1) {
                    Start-Sleep -Seconds 2
                }
            }
            
            Write-ColorOutput "`nCompleted: $successCount/$($installers.Count) installers ran successfully." -ForegroundColor Green
            break
        }
        else {
            # Parse space-separated numbers
            $numbers = $userInput.Trim().Split(' ', [StringSplitOptions]::RemoveEmptyEntries)
            $validNumbers = @()
            $invalidInputs = @()
            
            foreach ($num in $numbers) {
                if ($num -match '^[0-9]+$') {
                    $selectedIndex = [int]$num - 1
                    if ($selectedIndex -ge 0 -and $selectedIndex -lt $installers.Count) {
                        $validNumbers += $selectedIndex
                    }
                    else {
                        $invalidInputs += $num
                    }
                }
                else {
                    $invalidInputs += $num
                }
            }
            
            if ($invalidInputs.Count -gt 0) {
                Write-ColorOutput "Invalid input(s): $($invalidInputs -join ', '). Please enter numbers between 1 and $($installers.Count), or 'all'." -ForegroundColor Red
                continue
            }
            
            if ($validNumbers.Count -eq 0) {
                Write-ColorOutput "No valid installer numbers provided. Please enter numbers between 1 and $($installers.Count), or 'all'." -ForegroundColor Red
                continue
            }
            
            # Remove duplicates and sort
            $validNumbers = $validNumbers | Sort-Object -Unique
            
            if ($validNumbers.Count -eq 1) {
                Write-ColorOutput "`nRunning selected installer..." -ForegroundColor Yellow
            }
            else {
                Write-ColorOutput "`nRunning $($validNumbers.Count) selected installers..." -ForegroundColor Yellow
            }
            
            $successCount = 0
            for ($i = 0; $i -lt $validNumbers.Count; $i++) {
                $installerIndex = $validNumbers[$i]
                $selectedInstaller = $installers[$installerIndex]
                
                if (Invoke-Installer -InstallerPath $selectedInstaller.FullName -Index ($i + 1) -Total $validNumbers.Count) {
                    $successCount++
                }
                
                # Add a small delay between installers
                if ($i -lt $validNumbers.Count - 1) {
                    Start-Sleep -Seconds 2
                }
            }
            
            if ($validNumbers.Count -gt 1) {
                Write-ColorOutput "`nCompleted: $successCount/$($validNumbers.Count) selected installers ran successfully." -ForegroundColor Green
            }
            break
        }
    } while ($true)
}
catch {
    Write-ColorOutput "An unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
