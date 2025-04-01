@echo off
@taskkill /f /im WaveLink.exe >nul
@timeout /t 3 /nobreak >nul
@start C:\"Program Files"\Elgato\WaveLink\WaveLink.exe >nul
:exit 0
