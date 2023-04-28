function rehash {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

if ($host.Name -eq 'ConsoleHost')
{
  Import-Module PSReadLine
  Import-Module posh-git
  Import-Module -Name Terminal-Icons

  oh-my-posh --init --shell pwsh --config "$env:POSH_THEMES_PATH\M365Princess.omp.json" | Invoke-Expression
  Set-PSReadlineKeyHandler -Key Tab -Function Complete

  #Style
  set-psreadlineoption -PredictionViewStyle ListView
  set-psreadlineoption -PredictionViewStyle InlineView

# Autocompletion for arrow keys
  Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
# auto suggestions
  Set-PSReadLineOption -PredictionSource History
  Set-PSReadLineOption -EditMode Windows
  Set-PSReadLineOption -PredictionViewStyle ListView
  Set-PSReadlineOption -EditMode vi
}

# dir w/ fzf
# fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'

#Invoke-Expression (&starship init powershell)

$env:Path = [System.Environment]::ExpandEnvironmentVariables([System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"))
