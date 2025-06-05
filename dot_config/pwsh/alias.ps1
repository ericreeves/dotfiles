#Invoke-Expression (&scoop-search --hook) # Replace 'scoop search' with much faster 'scoop-search'
Invoke-Expression (& { (sfsu hook --disable list | Out-String) })

# Import alias management functions
. (Join-Path $PSScriptRoot "alias-manager.ps1")

# Import all aliases from JSON configuration
Import-Aliases

## Which
function which {
  param(
    [Parameter(Mandatory=$true)]
    [string]$Command
  )
  Get-Command -Name $Command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Update-ScoopApps {
    <#
    .SYNOPSIS
        Update all scoop apps if available.
    .DESCRIPTION
        Update all scoop apps includes globally installed apps if available.
        Then cleanup all old versions.
    #>
    scoop update --all
    scoop cleanup --all
}


