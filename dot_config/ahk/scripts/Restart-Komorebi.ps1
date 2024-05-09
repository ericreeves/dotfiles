. "$PSScriptRoot\Common.ps1"

Write-Output "--- Calling Stop-Komorebi.ps1"
Execute-Command -FilePath "powershell.exe" -ArgumentList "$PSScriptRoot\Stop-Komorebi.ps1"

Write-Output "--- Waiting 5 Seconds..."
Start-Sleep 5

Write-Output "--- Calling Start-Komorebi.ps1"
Execute-Command -FilePath "powershell.exe" -ArgumentList "$PSScriptRoot\Start-Komorebi.ps1"
