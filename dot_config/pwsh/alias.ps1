#Invoke-Expression (&scoop-search --hook) # Replace 'scoop search' with much faster 'scoop-search'
Invoke-Expression (& { (sfsu hook --disable list | Out-String) })

# Simple aliases (single commands only)
Set-Alias cat bat
Set-Alias vim nvim
Set-Alias vi nvim
Set-Alias lg lazygit
Set-Alias cm chezmoi
Set-Alias tf terraform
Set-Alias c clear
Set-Alias g git

# Function-based aliases for commands with arguments
function l { eza -l @args }
function tail { Get-Content @args -Wait -Tail 30 }
function grep { Select-String @args }
function gs { git status @args }
function tfp { terraform plan @args }
function tfa { terraform apply @args }
function tfaa { terraform apply -auto-approve @args }
function tfi { terraform init @args }
function tfiu { terraform init -upgrade @args }
function cmup { chezmoi update @args }
function cmdiff { chezmoi git pull -- --rebase; chezmoi diff --pager less @args }
function dml { doormat login -f @args }
function dmc { doormat aws console --account $( $Env:HASHI_AWS_ACCOUNT_ID ) @args }
function dmv { doormat login --validate @args }
function dmcf { doormat aws cred-file add-profile --set-default --account $( $Env:HASHI_AWS_ACCOUNT_ID ) @args }

function q { exit }
function e { explorer . }
function b { explorer shell:RecycleBinFolder }
function n { nvim . }
function w { wezterm cli spawn --new-window --cwd $pwd } # Opens a new window at the current directory
function t { wezterm cli spawn --cwd $pwd } # Opens a new tab at the current directory

## Which
function which {
  param(
    [Parameter(Mandatory=$true)]
    [string]$Command
  )
  Get-Command -Name $Command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Update-ScoopApps {
    <#
    .SYNOPSIS
        Update all scoop apps if available.
    .DESCRIPTION
        Update all scoop apps includes globally installed apps if available.
        Then cleanup all old versions.
    #>
    scoop update --all
    scoop cleanup --all
}


