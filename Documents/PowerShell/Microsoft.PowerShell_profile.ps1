function rehash {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
                ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

if ($host.Name -eq 'ConsoleHost')
{
  Import-Module PSReadLine
  Import-Module -Name Terminal-Icons

  Invoke-Expression (&starship init powershell)

# PSReadLine
  Set-PSReadlineOption -EditMode vi
  Set-PSReadlineKeyHandler -Key Tab -Function Complete

  #Style
  Set-PSReadlineOption -PredictionViewStyle InlineView

# Autocompletion for arrow keys
  Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
# auto suggestions
  Set-PSReadLineOption -PredictionSource History
}

# dir w/ fzf
# fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'


$env:Path = [System.Environment]::ExpandEnvironmentVariables([System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"))

Set-Alias -Name lvim -Value "$HOME\.local\bin\lvim.ps1"

