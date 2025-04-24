#Requires AutoHotkey v2.0
#SingleInstance Force

LockFile := A_Temp "\AutoPauseResume.lock"

; Simply create the lock file and exit
FileAppend("", LockFile)
ExitApp
