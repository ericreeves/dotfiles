#
# Environment 
# 
# [Environment]::SetEnvironmentVariable("XDG_CACHE_HOME", "$($HOME)\AppData\Local\Temp", "User")
# [Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "$($HOME)\AppData\Local", "User")
# [Environment]::SetEnvironmentVariable("XDG_DATA_HOME", "$($HOME)\AppData\Roaming", "User")
$Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
            ";" +
            [System.Environment]::GetEnvironmentVariable("Path","User")

#
# Aliases
#
Set-Alias -Name lvim -Value "$( $HOME )\.local\bin\lvim.ps1"
Set-Alias -Name vim -Value "$( $HOME )\.local\bin\lvim.ps1"
Set-Alias -Name l -Value "lsd -l"
Set-Alias -Name cm -Value "chezmoi"
Set-Alias -Name grep -Value "Select-String "
Invoke-Expression (&scoop-search --hook) # Replace 'scoop search' with much faster 'scoop-search'
#
# Prompt
#
if (Get-Command "starship" -ErrorAction SilentlyContinue) {
  $ENV:STARSHIP_CONFIG = "$( $HOME )/.config/starship.toml"
  # $ENV:STARSHIP_DISTRO = "SKY"
  Invoke-Expression (&starship init powershell)
}

if ($host.Name -eq 'ConsoleHost')
{
  Import-Module PSReadLine
  Import-Module -Name Terminal-Icons
  Invoke-Expression (& {
      $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
      (zoxide init --hook $hook powershell | Out-String)
  })
#
# PSReadLine
#
  Set-PSReadlineOption -EditMode vi
  Set-PSReadlineKeyHandler -Key Tab -Function Complete
  #Set-PSReadlineOption -PredictionViewStyle InlineView
  Set-PSReadlineOption -PredictionViewStyle ListView
  Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
  Set-PSReadLineOption -PredictionSource History
}

# dir w/ fzf
# fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'

#
# Get-Process-Command
#
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

function Execute-Command ($FilePath, $ArgumentList, $WorkingDirectory) {
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $FilePath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $ArgumentList
    $pinfo.WorkingDirectory = $WorkingDirectory
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    # [pscustomobject]@{
    #     stdout = $p.StandardOutput.ReadToEnd()
    #     stderr = $p.StandardError.ReadToEnd()
    #     ExitCode = $p.ExitCode
    # }
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

# Fix Prompt
Clear-Host
