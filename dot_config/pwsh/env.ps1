$Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path","User") + ";" +
            $Env:USERPROFILE + "\.local\bin" + ";" + 
            $Env:USERPROFILE + "\.cargo\bin" + ";" +
            $Env:USERPROFILE + "\.local\bin\cava"

# Utility Functions
function Test-CommandExists {
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

# Editor Configuration
$Env:EDITOR = if (Test-CommandExists nvim) { 'nvim' }
          elseif (Test-CommandExists vim) { 'vim' }
          elseif (Test-CommandExists vi) { 'vi' }
          elseif (Test-CommandExists code) { 'code' }
          else { 'notepad' }
Set-Alias -Name vim -Value $Env:EDITOR
Set-Alias -Name vi -Value $Env:EDITOR

# Set SHLVL to determine how many shells deep we are - used by starship prompt
$env:SHLVL = [int]$env:SHLVL + 1

#  Starship Debugging
# $Env:STARSHIP_LOG = "debug"

# Neovim Config
$Env:NVIM_LOG_FILE = $Env:USERPROFILE + "\.config\nvim-data"

# Development Config
$Env:LOCAL_CODE_HOME = $Env:USERPROFILE + "\code"

# Window Manager Config
$Env:KOMOREBI_CONFIG_HOME = $Env:USERPROFILE + "\.config\komorebi"
$Env:KOMOREBI_AHK_EXE = $Env:USERPROFILE + "\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey64.exe"
$Env:WHKD_CONFIG_HOME = $Env:USERPROFILE + "\.config\komorebi"

# FZF Config
$Env:FZF_FILE_OPTS = "--preview=`"bat --style=numbers --color=always {}`" --preview-window=border-rounded --preview-label=`" PREVIEW `" --border=rounded --border-label=`" FILES `" --tabstop=2 --color=16 --bind=ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up"
$Env:FZF_DIRECTORY_OPTS = "--preview=`"pwsh -NoProfile -Command Get-ChildItem -Force -LiteralPath '{}'`" --preview-window=border-rounded --preview-label=`" PREVIEW `" --border=rounded --border-label=`" DIRECTORIES `" --tabstop=2 --color=16 --bind=ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up"

Set-PsFzfOption -TabExpansion
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+h'

# PS Readline Config
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord 'Shift+Tab' -Function Complete
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# Enhanced PSReadLine Configuration
$PSReadLineOptions = @{
    EditMode = 'vi'
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
        Command = '#87CEEB'  # SkyBlue (pastel)
        Parameter = '#98FB98'  # PaleGreen (pastel)
        Operator = '#FFB6C1'  # LightPink (pastel)
        Variable = '#DDA0DD'  # Plum (pastel)
        String = '#FFDAB9'  # PeachPuff (pastel)
        Number = '#B0E0E6'  # PowderBlue (pastel)
        Type = '#F0E68C'  # Khaki (pastel)
        Comment = '#D3D3D3'  # LightGray (pastel)
        Keyword = '#8367c7'  # Violet (pastel)
        Error = '#FF6347'  # Tomato (keeping it close to red for visibility)
    }
    PredictionSource = 'HistoryAndPlugin'
    PredictionViewStyle = 'ListView'
    BellStyle = 'None'
    HistorySaveStyle = 'SaveIncrementally'
    MaximumHistoryCount = 10000

}
Set-PSReadLineOption @PSReadLineOptions

# Conda setup for python
If (Test-Path "C:\Users\eric\scoop\apps\miniconda3\current\Scripts\conda.exe") {
    (& "C:\Users\eric\scoop\apps\miniconda3\current\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
