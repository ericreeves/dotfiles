if (Test-Path $Env:USERPROFILE"\.config\pwsh\env-secret.ps1") { . $Env:USERPROFILE"\.config\pwsh\env-secret.ps1 }

. $Env:USERPROFILE"\.config\pwsh\modules.ps1"
. $Env:USERPROFILE"\.config\pwsh\env.ps1"
. $Env:USERPROFILE"\.config\pwsh\alias.ps1"
. $Env:USERPROFILE"\.config\pwsh\utility.ps1"


if (Get-Command "starship" -ErrorAction SilentlyContinue) {
  $ENV:STARSHIP_CONFIG = "$( $HOME )/.config/starship.toml"
  Invoke-Expression (&starship init powershell)
}
