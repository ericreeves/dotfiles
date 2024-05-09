@echo off
title startup script
nircmdc win hide title "startup script"
komorebic start

:: "komorebic start" currently is not waiting for everything be ready before return, so the
:: following lines prevent running commands bellow on startup before komorebi is ready to accept them
:wait_komorebi
komorebic state >nul 2>&1 || goto wait_komorebi

AutoHotKey.exe "%userprofile%"\.config\WindowsBox\ahk\komorebi.ahk
AutoHotKey.exe "%userprofile%"\.config\WindowsBox\ahk\AppShortcuts.ahk

:: optional, if you want to keep this script running for some reason
:: e.g.: I use this to auto restart my startup script if komorebi exit
nircmdc waitprocess komorebi.exe