# Extract ZIP files using native PowerShell functions
# Analyzes archive structure to determine extraction strategy

param(
    [Parameter(Mandatory=$true, HelpMessage="Specify the directory containing ZIP files to extract")]
    [ValidateScript({
        if (-not (Test-Path -Path $_ -PathType Container)) {
            throw "The specified path '$_' does not exist or is not a directory."
        }
        return $true
    })]
    [string]$Path
)

# Function to check ZIP contents and determine extraction strategy
function Get-ZipExtractionInfo {
    param([string]$ZipPath)
    
    try {
        # Load the ZIP file using .NET
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
        
        $rootFiles = @()
        $rootDirs = @()
        
        foreach ($entry in $zip.Entries) {
            # Skip empty entries (directories without trailing slash)
            if ($entry.Name -eq "") {
                continue
            }
            
            # Get the full path and normalize separators
            $fullPath = $entry.FullName.Replace('/', '\')
            
            # Check if this is a root-level item (no directory separators)
            if ($fullPath -notmatch '\\') {
                # This is a root-level file
                $rootFiles += $entry.Name
            }
            else {
                # Extract the root directory name
                $rootDirName = ($fullPath -split '\\')[0]
                if ($rootDirs -notcontains $rootDirName) {
                    $rootDirs += $rootDirName
                }
            }
        }
        
        $zip.Dispose()
        
        return @{
            HasRootFiles = ($rootFiles.Count -gt 0)
            HasRootDirs = ($rootDirs.Count -gt 0)
            RootFiles = $rootFiles
            RootDirs = $rootDirs
            NeedsSubdirectory = ($rootFiles.Count -gt 0)
        }
    }
    catch {
        Write-Warning "Could not analyze ZIP contents for '$ZipPath': $($_.Exception.Message)"
        # Default to creating subdirectory if we can't analyze
        return @{
            HasRootFiles = $true
            HasRootDirs = $false
            RootFiles = @()
            RootDirs = @()
            NeedsSubdirectory = $true
        }
    }
}

# Function to move file to recycle bin
function Move-ToRecycleBin {
    param([string]$FilePath)
    
    try {
        # Use Windows Shell to move file to recycle bin
        $shell = New-Object -ComObject Shell.Application
        $item = Get-Item -Path $FilePath
        $parentFolder = $shell.Namespace($item.DirectoryName)
        $file = $parentFolder.ParseName($item.Name)
        $file.InvokeVerb("delete")
        return $true
    }
    catch {
        Write-Warning "Failed to move '$FilePath' to recycle bin: $($_.Exception.Message)"
        return $false
    }
}

# Function to prompt user for overwrite confirmation
function Confirm-Overwrite {
    param([string]$DirectoryName)
    
    do {
        $response = Read-Host "Directory '$DirectoryName' already exists. Overwrite? (y/n/a/s) [y=yes, n=no, a=yes to all, s=skip all]"
        $response = $response.ToLower().Trim()
        
        switch ($response) {
            'y' { return 'yes' }
            'n' { return 'no' }
            'a' { return 'all' }
            's' { return 'skip' }
            default { 
                Write-Host "Please enter 'y' for yes, 'n' for no, 'a' for yes to all, or 's' for skip all."
                continue
            }
        }
    } while ($true)
}

# Main script execution
Write-Host "ZIP File Extraction Script using Native PowerShell" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green

# Check if Expand-Archive is available (PowerShell 5.0+)
if (-not (Get-Command -Name "Expand-Archive" -ErrorAction SilentlyContinue)) {
    Write-Error "This script requires PowerShell 5.0 or later with the Expand-Archive cmdlet."
    exit 1
}

# Get specified directory and resolve to full path
$workingPath = Resolve-Path -Path $Path
Write-Host "Working directory: $workingPath" -ForegroundColor Cyan

# Get all ZIP files in the specified directory
$zipFiles = Get-ChildItem -Path $workingPath -Filter "*.zip" -File

if ($zipFiles.Count -eq 0) {
    Write-Host "No ZIP files found in the current directory." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($zipFiles.Count) ZIP file(s) to extract:" -ForegroundColor Cyan
$zipFiles | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
Write-Host

# Variables for user choice persistence
$overwriteAll = $false
$skipAll = $false

# Process each ZIP file
foreach ($file in $zipFiles) {
    $fileName = $file.BaseName
    $fullPath = $file.FullName
    
    Write-Host "Processing: $($file.Name)" -ForegroundColor Yellow
    
    # Analyze ZIP contents to determine extraction strategy
    Write-Host "  Analyzing ZIP contents..." -ForegroundColor Cyan
    $zipInfo = Get-ZipExtractionInfo -ZipPath $fullPath
    
    if ($zipInfo.NeedsSubdirectory) {
        Write-Host "  ZIP contains root-level files - extracting to subdirectory" -ForegroundColor Gray
        if ($zipInfo.RootFiles.Count -gt 0) {
            Write-Host "    Root files: $($zipInfo.RootFiles -join ', ')" -ForegroundColor DarkGray
        }
        $targetDir = Join-Path -Path $workingPath -ChildPath $fileName
        $extractToSubdir = $true
    } else {
        Write-Host "  ZIP contains only directories - extracting to current directory" -ForegroundColor Gray
        if ($zipInfo.RootDirs.Count -gt 0) {
            Write-Host "    Root directories: $($zipInfo.RootDirs -join ', ')" -ForegroundColor DarkGray
        }
        $targetDir = $workingPath
        $extractToSubdir = $false
    }
    
    # Handle directory conflicts only if extracting to subdirectory
    if ($extractToSubdir) {
        if (Test-Path -Path $targetDir -PathType Container) {
            if ($skipAll) {
                Write-Host "  Skipping (directory exists): $fileName" -ForegroundColor Gray
                continue
            }
            
            if (-not $overwriteAll) {
                $choice = Confirm-Overwrite -DirectoryName $fileName
                
                switch ($choice) {
                    'no' { 
                        Write-Host "  Skipped: $fileName" -ForegroundColor Gray
                        continue 
                    }
                    'all' { 
                        $overwriteAll = $true 
                        Write-Host "  Will overwrite all existing directories" -ForegroundColor Magenta
                    }
                    'skip' { 
                        $skipAll = $true 
                        Write-Host "  Will skip all existing directories" -ForegroundColor Magenta
                        Write-Host "  Skipping: $fileName" -ForegroundColor Gray
                        continue
                    }
                }
            }
            
            # Remove existing directory if overwriting
            if ($overwriteAll -or $choice -eq 'yes') {
                try {
                    Remove-Item -Path $targetDir -Recurse -Force
                    Write-Host "  Removed existing directory: $fileName" -ForegroundColor Magenta
                }
                catch {
                    Write-Error "  Failed to remove existing directory '$fileName': $($_.Exception.Message)"
                    continue
                }
            }
        }
        
        # Create target directory
        try {
            New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
            Write-Host "  Created directory: $fileName" -ForegroundColor Green
        }
        catch {
            Write-Error "  Failed to create directory '$fileName': $($_.Exception.Message)"
            continue
        }
    }
    
    # Extract the ZIP file
    $extractionSuccessful = $false
    try {
        Write-Host "  Extracting..." -ForegroundColor Cyan
        
        # Use native PowerShell Expand-Archive
        Expand-Archive -Path $fullPath -DestinationPath $targetDir -Force
        
        # Check if extraction was successful by verifying files were created
        if ($extractToSubdir) {
            $extractedItems = Get-ChildItem -Path $targetDir -Recurse -ErrorAction SilentlyContinue
        } else {
            # For current directory extraction, we need to be more careful about verification
            # We'll assume success if no exception was thrown
            $extractedItems = @("success")  # Placeholder to indicate success
        }
        
        if ($extractedItems.Count -gt 0) {
            $extractionSuccessful = $true
            if ($extractToSubdir) {
                Write-Host "  Successfully extracted to: $fileName\" -ForegroundColor Green
            } else {
                Write-Host "  Successfully extracted to current directory" -ForegroundColor Green
            }
        } else {
            Write-Warning "  Extraction appeared successful but no files were found in target directory"
        }
    }
    catch {
        Write-Error "  Error extracting '$($file.Name)': $($_.Exception.Message)"
        $extractionSuccessful = $false
        
        # Clean up empty directory if extraction failed and we created one
        if ($extractToSubdir -and (Test-Path -Path $targetDir)) {
            try {
                if ((Get-ChildItem -Path $targetDir -Force -ErrorAction SilentlyContinue).Count -eq 0) {
                    Remove-Item -Path $targetDir -Force -ErrorAction SilentlyContinue
                }
            }
            catch {
                # Ignore cleanup errors
            }
        }
    }
    
    # Move ZIP file to recycle bin if extraction was successful
    if ($extractionSuccessful) {
        Write-Host "  Moving ZIP file to recycle bin..." -ForegroundColor Cyan
        if (Move-ToRecycleBin -FilePath $fullPath) {
            Write-Host "  ZIP file moved to recycle bin" -ForegroundColor Green
        } else {
            Write-Warning "  Extraction successful but could not move ZIP file to recycle bin"
        }
    }
    
    Write-Host
}

Write-Host "Extraction process completed!" -ForegroundColor Green
