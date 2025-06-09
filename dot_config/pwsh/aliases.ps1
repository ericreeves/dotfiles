### Linuxish
function cat { Get-Content $args } # Display file contents
function grep($pattern) { $input | Out-String -Stream| Select-String $pattern } # Search for text patterns
function kill { Stop-Process -Name $args[0] } # Kill process by name
function l { eza -l $args } # List directory contents in long format
function rmrf { # Recursive remove without confirmation - Usage: rmrf <path1> <path2> ... <pathN>
  $paths = $args
  foreach ($path in $paths) {
    if (Test-Path $path) { Remove-Item $path -Recurse -Force }
    else { Write-Output "Path does not exist: $path" }
  }
}
function tail { Get-Content $args -Wait -Tail 30 } # Display last 30 lines of file and follow changes
function touch { New-Item -ItemType file $args } # Create new empty file
# Display full path of command
function which {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Command
  )
  Get-Command -Name $Command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

### Terminal
function c { Clear-Host $args } # Clear the terminal screen
function q { exit } # Exit the current PowerShell session
function sysinfo { Get-ComputerInfo } # Display detailed system information
function flushdns { # Flush DNS cache
	Clear-DnsClientCache
	Write-Host "DNS has been flushed"
}
function reload { . $PROFILE } # Reload Powershell $PROFILE
function uza { UnzipAll -Path $args[0] }
function ww { wezterm cli spawn --new-window --cwd $pwd } # Open new WezTerm window at current directory
function wt { wezterm cli spawn --cwd $pwd } # Open new WezTerm tab at current directory

### Navigation
function gitroot { git rev-parse --show-toplevel }
function ~ {__zoxide_z ~} # Go to home directory
function .. {__zoxide_z ..} # Go up one directory level
function ... { # Navigate to git root if in a git repo
    if ((git rev-parse --is-inside-work-tree) -eq 'true') {
        __zoxide_z (gitroot)
    }
}
function b { __zoxide_z - } # Go back to previous directory
# function ffc { Invoke-FzfFileAction -Drive ($args[0] ?? 'd') -Action 'cd' } # Fuzzy find files and navigate to their directory
# function fdc { Invoke-FzfDirectoryAction -Drive ($args[0] ?? 'd') -Action 'cd' } # Fuzzy find directories and navigate to selected directory
function cdf { Invoke-FuzzySetLocation $args[0] } # Fuzzy find and change directory
function cde { Set-LocationFuzzyEverything } # Change directory based upon Everything context

### Search
function fh { Invoke-FuzzyHistory } # Fuzzy search command history
function fhc { # Searches your command history, sets your clipboard to the selected item - Usage: fhc [<string>]
  $find = $args
  $Env:FZF_DEFAULT_OPTS = "--border=rounded --border-label=`" HISTORY `" --tabstop=2 --color=16"
  $selected = Get-Content (Get-PSReadLineOption).HistorySavePath | Where-Object { $_ -like "*$find*" } | Sort-Object -Unique -Descending | fzf
  if (![string]::IsNullOrWhiteSpace($selected)) { Set-Clipboard $selected }
}
function fi ( # Fuzzy find and invoke selected item
    [parameter( Mandatory = $false )]
    [string] $Var = ""
    )
    { fzf -select1 --header="Invoke the sected item." -q $Var | Invoke-Item}
function fg { Invoke-PsFzfRipgrep -SearchString $args} # Fuzzy search text in files using ripgrep
function fkill { Invoke-FuzzyKillProcess } # Fuzzy find and kill process
function fs { Invoke-FuzzyScoop } # Fuzzy find scoop packages

### Clipboard
function cpy { Set-Clipboard $args[0] } # Copy text to clipboard
function pst { Get-Clipboard } # Paste text from clipboard

### Explorer
function e { explorer . } # Open Windows Explorer in current directory
function ffo { Invoke-FzfFileAction -SearchString ($args[0] ?? '') -Action 'invoke' } # Fuzzy find files and open their directory in Explorer
function fdo { Invoke-FzfDirectoryAction -SearchString ($args[0] ?? '') -Action 'explorer' } # Fuzzy find directories and open selected directory in Explorer
function rb { explorer shell:RecycleBinFolder } # Open Windows Recycle Bin

### Neovim
function n { nvim . } # Open current directory in Neovim
function ffe { Invoke-FzfFileAction -SearchString ($args[0] ?? '') -Action 'editor' } # Fuzzy find files and open their directory in Neovim
function fde { Invoke-FzfDirectoryAction -SearchString ($args[0] ?? '') -Action 'editor' } # Fuzzy find directories and open selected directory in Neovim

### Chezmoi
function cm { chezmoi $args } # Chezmoi dotfiles management command
function cma { chezmoi add $args } # Add files to chezmoi dotfiles
function cmar { chezmoi add -r $args } # Recursively add files to chezmoi dotfiles
function cmae { chezmoi add --encrypt $args } # Add and encrypt files in chezmoi
function cmu { chezmoi update $args } # Update chezmoi dotfiles from source
function cmdf { chezmoi git pull -- --rebase; chezmoi diff $args } # Pull latest changes and show differences

### Git
function fgs { Invoke-FuzzyGitStatus } # Fuzzy find and select git status items
function lg { lazygit $args } # Launch LazyGit terminal UI for Git operations
function g { git $args } # Git command shortcut
function gs { git status $args } # Show Git repository status
function ga { git add "$args" } # Add files to Git staging area
function gc { git commit -m "$args" } # Commit changes with message
# Add all files, commit with message, and push to remote
function gcp {
    git add .
    git commit -m "$args"
    git push
}
function ghrc { # Clone a repository using 'gh repo clone' - Usage: ghrc <repo_url> [local_directory]
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$RepoUrl,
    [Parameter(Position = 1)]
    [string]$LocalDirectory = $Env:LOCAL_CODE_HOME
  )
  
  # Parse repo name from URL
  $repoName = ""
  if ($RepoUrl -match "^https://github\.com/[^/]+/([^/]+?)(?:\.git)?/?$") {
    $repoName = $matches[1]
  }
  elseif ($RepoUrl -match "^[^/]+/([^/]+)$") {
    $repoName = $matches[1]
  }
  else {
    Write-Error "Invalid repository URL format. Use either 'https://github.com/USERNAME/REPONAME' or 'USERNAME/REPONAME'"
    return
  }
  
  # Construct full clone path
  $clonePath = Join-Path $LocalDirectory $repoName
  
  gh repo clone $RepoUrl $clonePath
  Set-Location $clonePath
}

### Terraform
function tf { terraform $args } # Terraform command shortcut
function tfp { terraform plan $args } # Show Terraform execution plan
function tfa { terraform apply $args } # Apply Terraform configuration changes
function tfaa { terraform apply -auto-approve $args } # Apply Terraform changes without confirmation
function tfdd { terraform destroy -auto-approve $args } # Destroy Terraform infrastructure without confirmation
function tfi { terraform init $args } # Initialize Terraform working directory
function tfiu { terraform init -upgrade $args } # Initialize Terraform and upgrade provider versions

### Doormat
function dml { doormat login -f $args } # Login to Doormat with force flag
function dmc { doormat aws console --account $( $Env:WORK_AWS_ACCOUNT_ID ) $args } # Open AWS console via Doormat
function dmv { doormat login --validate $args } # Validate Doormat login credentials
function dmcf { doormat aws cred-file add-profile --set-default --account $( $Env:WORK_AWS_ACCOUNT_ID ) $args } # Add AWS credentials profile and set as default
# Push AWS credentials to Terraform Variable set
function dmtp {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Variable_Set_ID
  )
  doormat aws tf-push variable-set --account $( $Env:WORK_AWS_ACCOUNT_ID ) --id $Varable_Set_ID
}
