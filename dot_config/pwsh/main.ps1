. $Env:USERPROFILE"\.config\pwsh\modules.ps1"
. $Env:USERPROFILE"\.config\pwsh\environment.ps1"
. $Env:USERPROFILE"\.config\pwsh\alias.ps1"
. $Env:USERPROFILE"\.config\pwsh\utility.ps1"

if (Get-Command "starship" -ErrorAction SilentlyContinue) {
  $ENV:STARSHIP_CONFIG = "$( $HOME )/.config/starship.toml"
  # $ENV:STARSHIP_DISTRO = "SKY"
  Invoke-Expression (&starship init powershell)
}
