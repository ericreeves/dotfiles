. $Env:USERPROFILE"\.config\pwsh\main.ps1"

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\eric\scoop\apps\miniconda3\current\Scripts\conda.exe") {
    (& "C:\Users\eric\scoop\apps\miniconda3\current\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion

