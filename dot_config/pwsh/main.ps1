if (Test-Path $Env:USERPROFILE"\.config\pwsh\env-secret.ps1") { . $Env:USERPROFILE"\.config\pwsh\env-secret.ps1" }

. $Env:USERPROFILE"\.config\pwsh\modules.ps1"
. $Env:USERPROFILE"\.config\pwsh\env.ps1"
. $Env:USERPROFILE"\.config\pwsh\alias.ps1"

# PS Readline Config
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineOption -EditMode vi
Set-PSReadlineOption -PredictionViewStyle ListView
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -PredictionSource History
# # https://gist.github.com/wilsnat/b51d2211c94d39536d6e84b59cb659bf
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 2000
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord 'Shift+Tab' -Function Complete
# Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

if (Get-Command "starship" -ErrorAction SilentlyContinue) {
  $ENV:STARSHIP_CONFIG = "$( $HOME )/.config/starship.toml"
  Invoke-Expression (&starship init powershell)
}

Invoke-Expression (& { (sfsu hook --disable list | Out-String) }) # Faster scoop searching
Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })