#Invoke-Expression (&scoop-search --hook) # Replace 'scoop search' with much faster 'scoop-search'
Invoke-Expression (& { (sfsu hook --disable list | Out-String) })

Set-ProfileAlias cat "bat #{*}" -Bash -Force
Set-ProfileAlias lvim "lvim.ps1 #{*}" -Bash -Force
Set-ProfileAlias vim "lvim.ps1 #{*}" -Bash -Force
Set-ProfileAlias vi "lvim.ps1 #{*}" -Bash -Force
Set-ProfileAlias lg "lazygit #{*}" -Bash -Force
Set-ProfileAlias tail "Get-Content #{*} -Wait -Tail 30" -Bash -Force
Set-ProfileAlias cm "chezmoi #{*}" -Bash -Force
Set-ProfileAlias cmup "chezmoi update" -Bash -Force
Set-ProfileAlias cmdiff "chezmoi git pull -- --rebase && chezmoi diff --pager less" -Bash -Force

Set-ProfileAlias tf "terraform" -Bash -Force
Set-ProfileAlias tfp "terraform plan" -Bash -Force
Set-ProfileAlias tfa "terraform apply" -Bash -Force
Set-ProfileAlias tfaa "terraform apply -auto-approve" -Bash -Force
Set-ProfileAlias tfi "terraform init" -Bash -Force
Set-ProfileAlias tfiu "terraform init -upgrade" -Bash -Force

Set-ProfileAlias gs "git status" -Bash -Force
Set-ProfileAlias grep "Select-String #{*}" -Force
Set-ProfileAlias l "eza -l" -Bash -Force
Set-ProfileAlias dml "doormat login -f" -Bash -Force
Set-ProfileAlias dmc "doormat aws console --account $( $Env:HASHI_AWS_ACCOUNT_ID )" -Bash -Force
Set-ProfileAlias dmv "doormat login --validate" -Bash -Force
Set-ProfileAlias dmcf "doormat aws cred-file add-profile --set-default --account $( $Env:HASHI_AWS_ACCOUNT_ID )" -Bash -Force

Set-ProfileAlias c "clear" -Bash -Force
Set-ProfileAlias g "git" -Bash -Force

function q { exit }
function e { explorer . }
function b { explorer shell:RecycleBinFolder }
function n { nvim . }
function w { wezterm cli spawn --new-window --cwd $pwd } # Opens a new window at the current directory
function t { wezterm cli spawn --cwd $pwd } # Opens a new tab at the current directory

#
# Get-Process-Command
#
function Get-Process-Command {
  param (
    [Parameter(Mandatory=$true)]
    [string]$Name
  )
  Get-WmiObject Win32_Process -Filter "name = '$Name.exe'" -ErrorAction SilentlyContinue | Select-Object CommandLine,ProcessId
}

function Wait-For-Process {
  param (
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Switch]$IgnoreExistingProcesses
  )
  if ($IgnoreExistingProcesses) {
      $NumberOfProcesses = (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
  } else {
      $NumberOfProcesses = 0
  }
  while ( (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count -eq $NumberOfProcesses ) {
      Start-Sleep -Milliseconds 400
  }
}

function Execute-Command ($FilePath, $ArgumentList, $WorkingDirectory) {
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $FilePath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $ArgumentList
    $pinfo.WorkingDirectory = $WorkingDirectory
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    # [pscustomobject]@{
    #     stdout = $p.StandardOutput.ReadToEnd()
    #     stderr = $p.StandardError.ReadToEnd()
    #     ExitCode = $p.ExitCode
    # }
}
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


