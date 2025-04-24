#Requires AutoHotkey v2.0
#SingleInstance Force
DetectHiddenWindows true

; Globals to manage the suspend/resume state
global IsProcessSuspended := false
global IsProcessResumed   := false

LockFile := A_Temp "\AutoPauseResume.lock"

; Ensure we clean up on script exit:
OnExit(Cleanup)

; Check if the lock file exists before deleting it
if FileExist(LockFile)
	FileDelete(LockFile)

; --------------------------------------------------------------------------
; 1) Define excluded processes as a map (key-value)
;    - The key is the process name in lowercase, mapped to `true`.
; --------------------------------------------------------------------------
excludedProcesses := Map()
excludedProcesses["explorer.exe"] := true
excludedProcesses["csrss.exe"]    := true
excludedProcesses["winlogon.exe"] := true
excludedProcesses["svchost.exe"]  := true
excludedProcesses["dwm.exe"]      := true
excludedProcesses["cmd.exe"]      := true
excludedProcesses["chrome.exe"]   := true
excludedProcesses["powershell.exe"]      := true
excludedProcesses["sublime_text.exe"]    := true
excludedProcesses["sublime_merge.exe"]   := true
excludedProcesses["steamwebhelper.exe"]  := true
excludedProcesses["openconsole.exe"]     := true
excludedProcesses["windowsterminal.exe"] := true
excludedProcesses["playnite.desktopapp.exe"]    := true
excludedProcesses["playnite.fullscreenapp.exe"] := true


; --------------------------------------------------------------------------
; 2) Get the active window's PID & Process Name, confirm it's not excluded
; --------------------------------------------------------------------------
if !WinExist("A")
{
	MsgBox "No active window detected. Please focus a window to suspend."
	ExitApp
}

pid := WinGetPID("A")
if !pid
{
	MsgBox "Failed to get the active window's PID."
	ExitApp
}

processName := WinGetProcessName()
if !processName
{
	MsgBox "Failed to retrieve the active window's process name."
	ExitApp
}

; Convert the process name to lowercase for case-insensitive matching
procLower := StrLower(processName)

; Check if `excludedProcesses` has this process in its keys, and if the value is true
if excludedProcesses.Has(procLower) && excludedProcesses[procLower]
{
	; Excluded process, so do nothing and exit.
	ExitApp
}

; --------------------------------------------------------------------------
; 3) Suspend the process & start checking for the lock file in a timer
; --------------------------------------------------------------------------
SuspendProcess(pid)
IsProcessSuspended := true  ; Mark that we have indeed suspended a process

; Optional: show a short tooltip or do a quick beep instead of a MsgBox
; MsgBox "Process '" processName "' (PID: " pid ") suspended. Waiting for lock file..."

SetTimer(CheckLockFile, 500)  ; check the lock file every 500 ms
return

; --------------------------------------------------------------------------
CheckLockFile(*)
{
	global LockFile, pid, processName, IsProcessResumed
	if FileExist(LockFile)
	{
		ResumeProcess(pid)
		IsProcessResumed := true

		; MsgBox "Process '" processName "' (PID: " pid ") resumed. Exiting."
		FileDelete(LockFile)
		ExitApp
	}
}

; --------------------------------------------------------------------------
SuspendProcess(pid)
{
	PROCESS_ALL_ACCESS := 0x1F0FFF
	hProc := DllCall("OpenProcess", "UInt", PROCESS_ALL_ACCESS, "Int", 0, "UInt", pid, "Ptr")
	if !hProc
	{
		MsgBox "Failed to open process (PID: " pid ")."
		ExitApp
	}

	hNtdll := DllCall("GetModuleHandle", "Str", "ntdll.dll", "Ptr")
	if !hNtdll
	{
		MsgBox "Failed to get module handle for ntdll.dll."
		ExitApp
	}

	NtSuspendProcess := DllCall("GetProcAddress", "Ptr", hNtdll, "AStr", "NtSuspendProcess", "Ptr")
	if !NtSuspendProcess
	{
		MsgBox "Failed to locate NtSuspendProcess in ntdll.dll."
		ExitApp
	}

	DllCall(NtSuspendProcess, "Ptr", hProc)
	DllCall("CloseHandle", "Ptr", hProc)
}

; --------------------------------------------------------------------------
ResumeProcess(pid)
{
	PROCESS_ALL_ACCESS := 0x1F0FFF
	hProc := DllCall("OpenProcess", "UInt", PROCESS_ALL_ACCESS, "Int", 0, "UInt", pid, "Ptr")
	if !hProc
	{
		; Process may no longer exist, don't do anything.
		; MsgBox "Failed to open process (PID: " pid ")."
		ExitApp
	}

	hNtdll := DllCall("GetModuleHandle", "Str", "ntdll.dll", "Ptr")
	if !hNtdll
	{
		MsgBox "Failed to get module handle for ntdll.dll."
		ExitApp
	}

	NtResumeProcess := DllCall("GetProcAddress", "Ptr", hNtdll, "AStr", "NtResumeProcess", "Ptr")
	if !NtResumeProcess
	{
		MsgBox "Failed to locate NtResumeProcess in ntdll.dll."
		ExitApp
	}

	DllCall(NtResumeProcess, "Ptr", hProc)
	DllCall("CloseHandle", "Ptr", hProc)
}

; --------------------------------------------------------------------------
; Automatically resume the process if the user manually exits the script
; or the script ends unexpectedly.
; --------------------------------------------------------------------------
Cleanup(exitReason, exitCode)
{
	global pid, IsProcessSuspended, IsProcessResumed
	; If the process was suspended and hasn't been resumed via the lock file,
	; auto-resume it here.
	if IsProcessSuspended && !IsProcessResumed
	{
		ResumeProcess(pid)
	}
}
