@echo off
@taskkill /f /im StreamDeck.exe >nul
@timeout /t 3 /nobreak >nul
@start C:\"Program Files"\Elgato\StreamDeck\StreamDeck.exe --runinbk >nul
:exit 0
