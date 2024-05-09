. "$PSScriptRoot\Common.ps1"
$ErrorActionPreference = 'SilentlyContinue'
Write-Output-Format "[yasb] Killing Process"
Get-Process -Name "pythonw3.9" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Wait-Process -Name "pythonw3.9" -ErrorAction SilentlyContinue

Start-Sleep 2

Write-Output-Format "[yasb] Checking for Processes"
Get-Process-Command -Name "pythonw3.9" -ErrorAction SilentlyContinue 

Write-Output ""

Write-Output-Format "[komorebi] Issuing komorebic stop"
Execute-Command -Title komorebi -FilePath "$Komorebi_Bin_Folder\komorebic.exe" -ArgumentList "stop" -WorkingDirectory "$PSScriptRoot" -ErrorAction SilentlyContinue 
Write-Output-Format "[komorebi] Terminating Remaining komorebi Processes"
Get-Process -Name "komorebi" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Wait-Process -Name "komorebi" -ErrorAction SilentlyContinue

Write-Output-Format "[komorebi] Checking for Processes"
Get-Process-Command -Name "komorebi" -ErrorAction SilentlyContinue 
