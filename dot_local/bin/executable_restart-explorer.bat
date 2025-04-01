@echo off
@taskkill /f /im explorer.exe >nul
@timeout /t 3 /nobreak >nul
@start "C:\Windows\explorer.exe" >nul
:exit 0
