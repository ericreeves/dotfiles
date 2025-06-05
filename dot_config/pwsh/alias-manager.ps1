function Import-Aliases {
  <#
    .SYNOPSIS
        Import and configure function aliases from a JSON file.
    .DESCRIPTION
        Reads alias definitions from a JSON file and creates PowerShell functions
        for each alias. The JSON file should contain an array of objects with
        'alias', 'command', and 'description' properties.
    .PARAMETER Path
        Path to the JSON file containing alias definitions. Defaults to alias.json
        in the same directory as this script.
    .EXAMPLE
        Import-Aliases
        Import-Aliases -Path "C:\custom\path\alias.json"
    #>
  param(
    [string]$Path = (Join-Path $PSScriptRoot 'alias.json')
  )

  if (-not (Test-Path $Path)) {
    Write-Error "Aliases file not found: $Path"
    return
  }

  try {
    $aliases = Get-Content $Path -Raw | ConvertFrom-Json
    $count = 0

    foreach ($alias in $aliases) {
      if (-not $alias.alias -or -not $alias.command) {
        Write-Warning "Skipping invalid alias entry: missing 'alias' or 'command' property"
        continue
      }

      # Create the function definition
      $functionBody = "{ $($alias.command) }"
      $functionDefinition = "function global:$($alias.alias) $functionBody"
            
      # Execute the function definition to create the function
      Invoke-Expression $functionDefinition
      $count++
    }

    Write-Host "Successfully imported $count aliases from $Path" -ForegroundColor Green
  } catch {
    Write-Error "Failed to import aliases: $($_.Exception.Message)"
  }
}

function Show-Aliases {
  <#
    .SYNOPSIS
        Display all imported aliases with their descriptions.
    .DESCRIPTION
        Reads the alias JSON file and displays a formatted table of all
        aliases with their commands and descriptions.
    .PARAMETER Path
        Path to the JSON file containing alias definitions.
    #>
  param(
    [string]$Path = (Join-Path $PSScriptRoot 'alias.json')
  )

  if (-not (Test-Path $Path)) {
    Write-Error "Aliases file not found: $Path"
    return
  }

  try {
    $aliases = Get-Content $Path -Raw | ConvertFrom-Json
    $aliases | Format-Table -Property alias, command, description -AutoSize
  } catch {
    Write-Error "Failed to read aliases: $($_.Exception.Message)"
  }
}

function Edit-Aliases {
  <#
    .SYNOPSIS
        Open the aliases JSON file for editing.
    .DESCRIPTION
        Opens the alias.json file in the default editor or specified editor.
    .PARAMETER Path
        Path to the JSON file containing alias definitions.
    .PARAMETER Editor
        Editor to use for opening the file. Defaults to notepad.
    #>
  param(
    [string]$Path = (Join-Path $PSScriptRoot 'alias.json'),
    [string]$Editor = 'notepad'
  )

  if (-not (Test-Path $Path)) {
    Write-Error "Aliases file not found: $Path"
    return
  }

  try {
    & $Editor $Path
  } catch {
    Write-Error "Failed to open aliases file: $($_.Exception.Message)"
  }
}
