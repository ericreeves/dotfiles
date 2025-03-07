Import-Module gsudoModule
Import-Module -Name HackF5.ProfileAlias -Force -Global -ErrorAction SilentlyContinue

# if ($host.Name -eq 'ConsoleHost')
# {
  Import-Module PSReadLine
  Import-Module -Name Terminal-Icons
  # Invoke-Expression (& {
  #     $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
  #     })
  #     (zoxide init --hook $hook powershell | Out-String)
  #
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
  Set-PSReadlineOption -EditMode vi
  Set-PSReadlineKeyHandler -Key Tab -Function Complete
  Set-PSReadlineOption -PredictionViewStyle ListView
  Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
  Set-PSReadLineOption -PredictionSource History
  # https://gist.github.com/wilsnat/b51d2211c94d39536d6e84b59cb659bf
  Set-PSReadLineOption -HistoryNoDuplicates
  Set-PSReadLineOption -HistorySearchCursorMovesToEnd
  Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
  Set-PSReadLineOption -MaximumHistoryCount 2000
  Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
  Set-PSReadLineKeyHandler -Chord 'Shift+Tab' -Function Complete
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# }
