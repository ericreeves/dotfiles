. "$PSScriptRoot\Common.ps1"

$ErrorActionPreference = 'SilentlyContinue'

Write-Output-Format "[komorebi] Killing prior komorebi.exe Processes"
Get-Process -Name "komorebi" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output-Format "[komorebi] Running komorebic.exe start"
Execute-Command -Title komorebi -FilePath "$Komorebi_Bin_Folder\komorebic.exe" -ArgumentList "start" -WorkingDirectory "$PSScriptRoot" -ErrorAction SilentlyContinue 
Wait-For-Process -Name "komorebi"

Write-Output-Format "[komorebi] Sleeping for 5 Seconds..."
Start-Sleep 5

Write-Output-Format "[yasb] Starting yasb"
Start-Process -FilePath "$Python_Bin_Folder\pythonw.exe" -ArgumentList "src/main.py" -WorkingDirectory "$Yasb_Folder" -WindowStyle Hidden -ErrorAction SilentlyContinue 

Wait-For-Process -Name "pythonw"

Write-Output-format "[ahk] Starting AutoHotKey"
"AutoHotKey.exe $AHK_Folder\$AHK_Filename"
"AutoHotKey.exe $AHK_Folder\$AHK_Shortcuts_Filename"