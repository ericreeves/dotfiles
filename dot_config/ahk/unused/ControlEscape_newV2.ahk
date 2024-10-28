; REMOVED: #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.

~LCtrl up::
{ ; V1toV2: Added bracket
	If (A_PriorKey = "LControl") {
		Send("{Esc}")
	}
} ; V1toV2: Added bracket in the end
