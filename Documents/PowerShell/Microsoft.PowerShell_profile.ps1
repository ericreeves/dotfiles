function rehash {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Prompt
if (Get-Command "starship" -ErrorAction SilentlyContinue) {
  $ENV:STARSHIP_CONFIG = "$( $HOME )/.config/starship.toml"
  # $ENV:STARSHIP_DISTRO = "SKY"
  Invoke-Expression (&starship init powershell)
}


if ($host.Name -eq 'ConsoleHost')
{
  Import-Module PSReadLine
  Import-Module -Name Terminal-Icons

# PSReadLine
  Set-PSReadlineOption -EditMode vi
  Set-PSReadlineKeyHandler -Key Tab -Function Complete

  #Style
  #Set-PSReadlineOption -PredictionViewStyle InlineView
  Set-PSReadlineOption -PredictionViewStyle ListView

# Autocompletion for arrow keys
  Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
# auto suggestions
  Set-PSReadLineOption -PredictionSource History
}

# Prompt
if (Get-Command "starship" -ErrorAction SilentlyContinue) {
  $ENV:STARSHIP_CONFIG = "$( $HOME )/.config/starship.toml"
  # $ENV:STARSHIP_DISTRO = "SKY"
  Invoke-Expression (&starship init powershell)
}

# dir w/ fzf
# fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'

$Env:KOMOREBI_CONFIG_HOME = 'C:\Users\LGUG2Z\.config\komorebi'

$Env:PATH = [System.Environment]::ExpandEnvironmentVariables([System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"))

Set-Alias -Name lvim -Value "$HOME\.local\bin\lvim.ps1"
Set-Alias -Name vim -Value "$HOME\.local\bin\lvim.ps1"
Set-Alias -Name l -Value "lsd -l"


function Get-Process-Command {
  param (
      [Parameter(Mandatory=$true)]
      [string]$Name
  )
  Get-WmiObject Win32_Process -Filter "name = '$Name.exe'" -ErrorAction SilentlyContinue | Select-Object CommandLine,ProcessId
}

function Wait-For-Process {
  param (
      [Parameter(Mandatory=$true)]
      [string]$Name,

      [Switch]$IgnoreExistingProcesses
  )

  if ($IgnoreExistingProcesses) {
      $NumberOfProcesses = (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
  } else {
      $NumberOfProcesses = 0
  }

  while ( (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count -eq $NumberOfProcesses ) {
      Start-Sleep -Milliseconds 400
  }
}

## Which
function which {
  param(
      [Parameter(Mandatory=$true)]
      [string]$Command
  )

  Get-Command -Name $Command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}


if (Get-Command "komorebic" -ErrorAction SilentlyContinue) {
  $ENV:KOMOREBI_CONFIG_HOME = "$( $HOME )/.config/komorebi"
  $ENV:KOMOREBI_AHK_EXE = "$( $HOME )/scoop/apps/autohotkey/current/AutoHotkey64.exe"

  function start-tiling {
      Write-Host "[komorebi] Killing prior komorebi.exe Processes"
      Get-Process -Name "komorebi" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

      Write-Host "[komorebi] Running komorebic.exe start"
      Execute-Command -FilePath "$( $HOME )/scoop/apps/komorebi/current/komorebic.exe" -ArgumentList "start" -WorkingDirectory "$( $HOME )/.config/komorebi" -ErrorAction SilentlyContinue
      Wait-For-Process -Name "komorebi"
      Start-Sleep 3

      Write-Host "[ahk] Starting AutoHotKey"
      Execute-Command -FilePath "$( $HOME )/scoop/apps/autohotkey/current/AutoHotkey64.exe" -ArgumentList "$( $HOME )/.config/komorebi/komorebi.ahk" -WorkingDirectory "$( $HOME )/.config/komorebi" -ErrorAction SilentlyContinue
  }

  function stop-tiling {
      Write-Host "[komorebi] Issuing komorebic stop"

      Execute-Command -FilePath "$( $HOME )/scoop/apps/komorebi/current/komorebic.exe" -ArgumentList "stop" -WorkingDirectory "$( $HOME )/.config/komorebi" -ErrorAction SilentlyContinue
      Write-Host "[komorebi] Terminating Remaining komorebi Processes"
      Get-Process -Name "komorebi" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
      Wait-Process -Name "komorebi" -ErrorAction SilentlyContinue

      Write-Host "[komorebi] Checking for Processes"
      Get-Process-Command -Name "komorebi" -ErrorAction SilentlyContinue

      Write-Host "[ahk] Killing Process"
      Get-Process -Name "AutoHotKey" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
      Wait-Process -Name "AutoHotKey" -ErrorAction SilentlyContinue
  }

}

# Fix Prompt
Clear-Host
