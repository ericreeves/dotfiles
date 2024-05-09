. "$PSScriptRoot\Common.ps1"
$ErrorActionPreference = 'SilentlyContinue'
Write-Output-Format "[AHK] Killing Process"
Get-Process -Name "AutoHotKey" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Wait-Process -Name "AutoHotKey" -ErrorAction SilentlyContinue