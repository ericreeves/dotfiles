Get-ChildItem "$PSScriptRoot\*.ahk" | ForEach-Object {
    Start-Process $_.FullName
}