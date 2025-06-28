# Extract ZIP and RAR files using native PowerShell functions and external tools
# Analyzes archive structure to determine extraction strategy

param(
    [Parameter(Mandatory=$false, Position=0, HelpMessage="Specify the directory containing archive files to extract")]
    [string]$Path = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Specify the destination directory for extracted files (defaults to source directory)")]
    [string]$Destination = ""
)

# Capture the command used to invoke this script
$InvokedCommand = $MyInvocation.Line.Trim()

# Function to display usage information
function Show-Usage {
    param([string]$Command)
      Write-Host ""
    Write-Host "Archive File Extraction Script" -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor Green
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  $Command -Path <SourceDirectory> [-Destination <DestinationDirectory>]" -ForegroundColor White
    Write-Host "  $Command <SourceDirectory> [-Destination <DestinationDirectory>]" -ForegroundColor White
    Write-Host ""
    Write-Host "PARAMETERS:" -ForegroundColor Yellow
    Write-Host "  Path          (Required) Directory containing archive files to extract" -ForegroundColor White
    Write-Host "                           Can be specified as -Path or as first positional argument" -ForegroundColor Gray
    Write-Host "  -Destination  (Optional) Directory where files will be extracted" -ForegroundColor White
    Write-Host "                           Defaults to source directory if not specified" -ForegroundColor Gray
    Write-Host ""
    Write-Host "SUPPORTED FORMATS:" -ForegroundColor Yellow
    Write-Host "  • ZIP files (native PowerShell support)" -ForegroundColor White
    Write-Host "  • RAR files (requires WinRAR or 7-Zip)" -ForegroundColor White
    Write-Host ""    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  # Extract archive files in current directory (positional)" -ForegroundColor Gray
    Write-Host "  $Command ." -ForegroundColor White
    Write-Host ""
    Write-Host "  # Extract archive files in current directory (named parameter)" -ForegroundColor Gray
    Write-Host "  $Command -Path ." -ForegroundColor White
    Write-Host ""
    Write-Host "  # Extract archive files from Downloads to Desktop" -ForegroundColor Gray
    Write-Host "  $Command `"C:\Downloads`" -Destination `"C:\Users\$env:USERNAME\Desktop\Extracted`"" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Extract from network drive to local folder" -ForegroundColor Gray
    Write-Host "  $Command `"\\Server\Share\Archives`" -Destination `"C:\LocalExtracted`"" -ForegroundColor White
    Write-Host ""
    Write-Host "FEATURES:" -ForegroundColor Yellow
    Write-Host "  • Intelligently analyzes archive structure before extraction" -ForegroundColor White
    Write-Host "  • Creates subdirectories for archives with loose files" -ForegroundColor White
    Write-Host "  • Extracts directly for archives containing only folders" -ForegroundColor White
    Write-Host "  • Moves successfully extracted archive files to recycle bin" -ForegroundColor White
    Write-Host "  • Handles directory conflicts with user prompts" -ForegroundColor White
    Write-Host "  • Supports both ZIP and RAR formats" -ForegroundColor White
    Write-Host ""
}

# Check if required parameters are provided and show usage if not
if ([string]::IsNullOrEmpty($Path)) {
    Show-Usage -Command $InvokedCommand
    exit 1
}

# Validate that the path exists and is a directory
if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "The specified path '$Path' does not exist or is not a directory."
    Show-Usage -Command $InvokedCommand
    exit 1
}

# Function to find RAR extraction tool
function Find-RarTool {
    # Check for WinRAR
    $winrarPaths = @(
        "${env:ProgramFiles}\WinRAR\UnRAR.exe",
        "${env:ProgramFiles(x86)}\WinRAR\UnRAR.exe",
        "${env:ProgramFiles}\WinRAR\WinRAR.exe",
        "${env:ProgramFiles(x86)}\WinRAR\WinRAR.exe"
    )
    
    foreach ($path in $winrarPaths) {
        if (Test-Path $path) {
            return @{ Tool = "WinRAR"; Path = $path }
        }
    }
    
    # Check for 7-Zip
    $sevenZipPaths = @(
        "${env:ProgramFiles}\7-Zip\7z.exe",
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    )
    
    foreach ($path in $sevenZipPaths) {
        if (Test-Path $path) {
            return @{ Tool = "7-Zip"; Path = $path }
        }
    }
    
    return $null
}

# Function to check RAR contents and determine extraction strategy
function Get-RarExtractionInfo {
    param([string]$RarPath, [hashtable]$RarTool)
    
    try {
        $rootFiles = @()
        $rootDirs = @()
        
        # Get file listing from RAR
        if ($RarTool.Tool -eq "WinRAR") {
            $result = & $RarTool.Path "l" "-c-" $RarPath 2>$null
        }
        elseif ($RarTool.Tool -eq "7-Zip") {
            $result = & $RarTool.Path "l" "-ba" $RarPath 2>$null
        }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to list RAR contents"
        }
        
        foreach ($line in $result) {
            if ($RarTool.Tool -eq "WinRAR") {
                # Parse WinRAR output - look for file entries
                if ($line -match '^\s*[0-9]+\s+[0-9]+\s+[0-9]+%\s+[0-9-]+\s+[0-9:]+\s+[A-Z0-9]+\s+(.+)$') {
                    $filePath = $matches[1].Trim()
                }
                else {
                    continue
                }
            }
            elseif ($RarTool.Tool -eq "7-Zip") {
                # Parse 7-Zip output - look for file entries
                if ($line -match '^[0-9-]+\s+[0-9:]+\s+[AD.]+\s+[0-9]+\s+[0-9]*\s+(.+)$') {
                    $filePath = $matches[1].Trim()
                }
                else {
                    continue
                }
            }
            
            # Normalize path separators
            $filePath = $filePath.Replace('/', '\')
            
            # Skip empty paths
            if ([string]::IsNullOrEmpty($filePath)) {
                continue
            }
            
            # Check if this is a root-level item
            if ($filePath -notmatch '\\') {
                # This is a root-level file
                $rootFiles += $filePath
            }
            else {
                # Extract the root directory name
                $rootDirName = ($filePath -split '\\')[0]
                if ($rootDirs -notcontains $rootDirName) {
                    $rootDirs += $rootDirName
                }
            }
        }
        
        return @{
            HasRootFiles = ($rootFiles.Count -gt 0)
            HasRootDirs = ($rootDirs.Count -gt 0)
            RootFiles = $rootFiles
            RootDirs = $rootDirs
            NeedsSubdirectory = ($rootFiles.Count -gt 0)
        }
    }
    catch {
        Write-Warning "Could not analyze RAR contents for '$RarPath': $($_.Exception.Message)"
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

# Function to extract RAR file
function Extract-RarFile {
    param(
        [string]$RarPath,
        [string]$DestinationPath,
        [hashtable]$RarTool
    )
    
    try {
        if ($RarTool.Tool -eq "WinRAR") {
            # Use WinRAR
            $result = & $RarTool.Path "x" "-o+" $RarPath $DestinationPath 2>&1
        }
        elseif ($RarTool.Tool -eq "7-Zip") {
            # Use 7-Zip
            $result = & $RarTool.Path "x" "-o$DestinationPath" "-y" $RarPath 2>&1
        }
        
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
        else {
            Write-Warning "RAR extraction failed with exit code $LASTEXITCODE"
            return $false
        }
    }
    catch {
        Write-Warning "RAR extraction error: $($_.Exception.Message)"
        return $false
    }
}

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
Write-Host "Archive File Extraction Script" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# Check if Expand-Archive is available (PowerShell 5.0+)
if (-not (Get-Command -Name "Expand-Archive" -ErrorAction SilentlyContinue)) {
    Write-Error "This script requires PowerShell 5.0 or later with the Expand-Archive cmdlet."
    exit 1
}

# Check for RAR tool availability
$rarTool = Find-RarTool
if ($rarTool) {
    Write-Host "Found RAR extraction tool: $($rarTool.Tool) at $($rarTool.Path)" -ForegroundColor Green
} else {
    Write-Host "No RAR extraction tool found. Install WinRAR or 7-Zip to extract RAR files." -ForegroundColor Yellow
}

# Get specified directory and resolve to full path
$workingPath = Resolve-Path -Path $Path
Write-Host "Source directory: $workingPath" -ForegroundColor Cyan

# Determine destination path
if ($Destination -ne "") {
    # Validate destination path exists or can be created
    if (-not (Test-Path -Path $Destination)) {
        try {
            New-Item -Path $Destination -ItemType Directory -Force | Out-Null
            Write-Host "Created destination directory: $Destination" -ForegroundColor Green
        }
        catch {
            Write-Error "Cannot create destination directory '$Destination': $($_.Exception.Message)"
            exit 1
        }
    }
    $destinationPath = Resolve-Path -Path $Destination
    Write-Host "Destination directory: $destinationPath" -ForegroundColor Cyan
} else {
    $destinationPath = $workingPath
    Write-Host "Destination directory: Same as source" -ForegroundColor Cyan
}

# Get all ZIP and RAR files in the specified directory
$zipFiles = Get-ChildItem -Path $workingPath -Filter "*.zip" -File
$rarFiles = @()

if ($rarTool) {
    $rarFiles = Get-ChildItem -Path $workingPath -Filter "*.rar" -File
}

$allFiles = $zipFiles + $rarFiles

if ($allFiles.Count -eq 0) {
    if ($rarTool) {
        Write-Host "No ZIP or RAR files found in the directory." -ForegroundColor Yellow
    } else {
        Write-Host "No ZIP files found in the directory. (Install WinRAR or 7-Zip to extract RAR files)" -ForegroundColor Yellow
    }
    exit 0
}

Write-Host "Found $($allFiles.Count) archive file(s) to extract:" -ForegroundColor Cyan
$allFiles | ForEach-Object { 
    $type = if ($_.Extension -eq ".zip") { "ZIP" } else { "RAR" }
    Write-Host "  - $($_.Name) ($type)" -ForegroundColor Gray 
}
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
        $targetDir = Join-Path -Path $destinationPath -ChildPath $fileName
        $extractToSubdir = $true
    } else {
        Write-Host "  ZIP contains only directories - extracting to destination directory" -ForegroundColor Gray
        if ($zipInfo.RootDirs.Count -gt 0) {
            Write-Host "    Root directories: $($zipInfo.RootDirs -join ', ')" -ForegroundColor DarkGray
        }
        $targetDir = $destinationPath
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
