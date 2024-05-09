. "$PSScriptRoot\Common.ps1"
$ErrorActionPreference = 'SilentlyContinue'

Write-Output-Format "[yasb] Copying Configs to .yasb"
New-Item -ItemType Directory -Force -Path $Yasb_Config_Folder
$ConfigFiles = Get-ChildItem -Path "$WindowsBox_Folder\yasb-config\" -File
foreach ($ConfigFile in $ConfigFiles)
{
    Write-Output-Format "[yasb] Copying $ConfigFile to .yasb"
	Copy-Item "$WindowsBox_Folder\yasb-config\$ConfigFile" "$Yasb_Config_Folder" -force
}

Write-Output-Format "[yasb] Starting yasb"
Start-Process -FilePath "$Python_Bin_Folder\pythonw.exe" -ArgumentList "src/main.py" -WorkingDirectory "$Yasb_Folder" -WindowStyle Hidden

# Wait-For-Process -Name "pythonw"

Write-Output-format "[ahk] Starting AutoHotKey"
"AutoHotKey.exe $AHK_Folder\$AHK_Filename"