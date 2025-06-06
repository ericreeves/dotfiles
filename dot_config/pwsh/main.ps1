# Install/Load all required Powershell modules
. $Env:USERPROFILE"\.config\pwsh\modules.ps1"

# Load environment variables
. $Env:USERPROFILE"\.config\pwsh\env.ps1"

# Load secret environment variables, if present
if (Test-Path $Env:USERPROFILE"\.config\pwsh\env-secret.ps1") { . $Env:USERPROFILE"\.config\pwsh\env-secret.ps1" }

# Load all function files (internal functions, not documented)
$functionsPath = Join-Path $Env:USERPROFILE ".config\pwsh\functions"
if (Test-Path $functionsPath) {
    Get-ChildItem "$functionsPath\*.ps1" | ForEach-Object { . $_.FullName }
}

# Load aliases.ps1 (user-facing functions, documented)
. $Env:USERPROFILE"\.config\pwsh\aliases.ps1"

# Custom PowerShell prompt with clean formatting and window title updates
# function prompt { 
#   $p = Split-Path -Leaf -Path (Get-Location)
#   $Host.UI.RawUI.WindowTitle = "$p"
#   "$pwd> "
# }

# Starship prompt
if (Get-Command "starship" -ErrorAction SilentlyContinue) {
  $ENV:STARSHIP_CONFIG = "$( $HOME )/.config/starship.toml"
  Invoke-Expression (&starship init powershell)
}

Invoke-Expression (& { (sfsu hook --disable list | Out-String) }) # Faster scoop searching
Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) }) # Enable zoxide