### Help and Documentation
function Show-AliasHelp {
    <#
    .SYNOPSIS
        Parse aliases.ps1 and display a formatted help page with all available functions.
    .DESCRIPTION
        Reads the current aliases.ps1 file, extracts function definitions and their categories,
        and displays them in a formatted help page grouped by section.
    .PARAMETER Category
        Show only functions from a specific category (e.g., "Git", "Terminal", "FZF").
    .EXAMPLE
        Show-AliasHelp
        Show-AliasHelp -Category "Git"
    #>
    param(
        [string]$Category = ""
    )

    $aliasPath = Join-Path $PSScriptRoot "..\aliases.ps1"
    if (-not (Test-Path $aliasPath)) {
        Write-Error "Alias file not found: $aliasPath"
        return
    }

    $content = Get-Content $aliasPath
    $sections = @{}
    $sectionOrder = @()
    $currentSection = "Uncategorized"
    $pendingDescription = ""
    
    foreach ($line in $content) {
        # Check for section headers (### SectionName)
        if ($line -match '^###\s*(.+)') {
            $currentSection = $matches[1].Trim()
            if (-not $sections.ContainsKey($currentSection)) {
                $sections[$currentSection] = @()
                $sectionOrder += $currentSection
            }
        }
        # Check for standalone comment descriptions (for multi-line functions)
        elseif ($line -match '^#\s*(.+)' -and $line -notmatch 'function') {
            $pendingDescription = $matches[1].Trim()
        }
        # Check for function definitions (including those with parameter blocks and special characters)
        elseif ($line -match '^function\s+([^\s\{]+)\s*(.*)') {
            $functionName = $matches[1]
            $functionRest = $matches[2].Trim()
            
            # Handle functions with opening brace on same line
            if ($functionRest -match '\{(.*)') {
                $functionBody = $matches[1].Trim()
            } else {
                $functionBody = ""
            }
            
            # Extract description from inline comments
            $description = ""
            if ($line -match '#\s*(.+)') {
                $description = $matches[1].Trim()
            } elseif ($pendingDescription) {
                $description = $pendingDescription
                $pendingDescription = ""
            }
            
            # Skip functions without descriptions (treat as private)
            if ([string]::IsNullOrWhiteSpace($description)) {
                $pendingDescription = ""
                continue
            }
            
            if (-not $sections.ContainsKey($currentSection)) {
                $sections[$currentSection] = @()
                $sectionOrder += $currentSection
            }
            
            $sections[$currentSection] += [PSCustomObject]@{
                Name = $functionName
                Body = $functionBody
                Description = $description
            }
            
            # Clear pending description after use
            $pendingDescription = ""
        }
    }
    
    # Calculate maximum function name length for alignment
    $maxNameLength = 0
    foreach ($section in $sectionOrder) {
        if ($Category -and $section -notmatch $Category) {
            continue
        }
        foreach ($func in $sections[$section]) {
            if ($func.Name.Length -gt $maxNameLength) {
                $maxNameLength = $func.Name.Length
            }
        }
    }
    
    # Display the help page
    Write-Host "`nPowerShell Alias Help" -ForegroundColor Cyan
    Write-Host ("=" * 50) -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($section in $sectionOrder) {
        # Filter by category if specified
        if ($Category -and $section -notmatch $Category) {
            continue
        }
        
        Write-Host $section -ForegroundColor Yellow
        Write-Host ("-" * $section.Length) -ForegroundColor Yellow
        
        # Display functions in the order they appear in the file (no sorting)
        $functions = $sections[$section]
        foreach ($func in $functions) {
            $paddedName = $func.Name.PadRight($maxNameLength)
            Write-Host "  $paddedName" -ForegroundColor Green -NoNewline
            if ($func.Description) {
                Write-Host " - $($func.Description)" -ForegroundColor Gray
            } else {
                Write-Host " - $($func.Body)" -ForegroundColor DarkGray
            }
        }
        Write-Host ""
    }
    
    Write-Host "Usage: aliases [-Category <CategoryName>]" -ForegroundColor Cyan
    Write-Host "Available categories: $($sections.Keys -join ', ')" -ForegroundColor White
    Write-Host ""
}

Set-Alias aliases Show-AliasHelp