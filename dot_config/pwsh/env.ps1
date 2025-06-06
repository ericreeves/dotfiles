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

# Neovim Config
$Env:NVIM_LOG_FILE = $Env:USERPROFILE + "/.config/nvim-data"

# Window Manager Config
$Env:KOMOREBI_CONFIG_HOME = $Env:USERPROFILE + "/.config/komorebi"
$Env:WHKD_CONFIG_HOME = $Env:USERPROFILE + "/.config/komorebi"

# FZF Config
$Env:FZF_FILE_OPTS = "--preview=`"bat --style=numbers --color=always {}`" --preview-window=border-rounded --preview-label=`" PREVIEW `" --border=rounded --border-label=`" FILES `" --tabstop=2 --color=16 --bind=ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up"
$Env:FZF_DIRECTORY_OPTS = "--preview=`"pwsh -NoProfile -Command Get-ChildItem -Force -LiteralPath '{}'`" --preview-window=border-rounded --preview-label=`" PREVIEW `" --border=rounded --border-label=`" DIRECTORIES `" --tabstop=2 --color=16 --bind=ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up"
