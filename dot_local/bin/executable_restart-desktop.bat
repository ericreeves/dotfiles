powershell.exe -File "%USERPROFILE%\.local\bin\wpm.ps1" stop
taskkill /f /im explorer.exe
start explorer.exe
powershell.exe -File "%USERPROFILE%\.local\bin\wpm.ps1" start
