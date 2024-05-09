; # Win (Windows logo key)
; ! Alt
; ^ Control
; + Shift
; & An ampersand may be used between any two keys or mouse buttons to combine them into a custom hotkey.
;
; https://www.autohotkey.com/docs/v1/KeyList.htm
;

; ; https://www.reddit.com/r/AutoHotkey/comments/z989gy/windows_11_taskbar_hide_script_not_working_anymore/
; Global ABM_GETSTATE := 0x4
; Global ABM_SETSTATE := 0xA
; Global ABS_NORMAL := 0x0
; Global ABS_AUTOHIDE := 0x1

; SendTaskbarMessage(Message, Parameter := 0) {
;    ; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shappbarmessage
;    ; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/ns-shellapi-appbardata
;    ; typedef struct _AppBarData {
;    ;  DWORD  cbSize;
;    ;  HWND   hWnd;
;    ;  UINT   uCallbackMessage;
;    ;  UINT   uEdge;
;    ;  RECT   rc;
;    ;  LPARAM lParam;
;    ;  } APPBARDATA, *PAPPBARDATA;

;    ; hWnd is aligned, so cbSize is not 4 bytes but pointer size
;    AppBarData := Buffer(A_PtrSize + A_PtrSize + 4 + 4 + 16 + A_PtrSize, 0)

;    NumPut("UInt", AppBarData.Size, AppBarData)
;    NumPut("Int64", Parameter, AppBarData, AppBarData.Size - A_PtrSize)

;    return DllCall("Shell32\SHAppBarMessage", "UInt", Message, "Ptr", AppBarData)
; }

; EnableAutoHideTaskbar() {
;    SendTaskbarMessage(ABM_SETSTATE, ABS_AUTOHIDE)
; }

; DisableAutoHideTaskbar() {
;    SendTaskbarMessage(ABM_SETSTATE, ABS_NORMAL)
; }

; ToggleAutoHideTaskbar() {
;    if (SendTaskbarMessage(ABM_GETSTATE) = ABS_AUTOHIDE) {
;       DisableAutoHideTaskbar()
;    } else {
;       EnableAutoHideTaskbar()
;    }
; }

; #Z::ToggleAutoHideTaskbar()


; ^![::Run("C:\Users\eric\.local\bin\rainmeter-stop.bat") ; Ctrl+Alt+R
; ^!]::Run("C:\Users\eric\.local\bin\rainmeter-start.bat") ; Ctrl+Alt+R

; #Requires AutoHotkey v2.0

; #SingleInstance Force
; SendMode("Input")
; SetWorkingDir(A_ScriptDir)

; $CapsLock::Ctrl 

; #s::Send("{PrintScreen}")

; ::zoomlink::https://hashicorp.zoom.us/j/9101845328?pwd=WXRFQ3VJWGdwQWdNRGhxZHAyRXJBUT09

; ; Hide or Show Taskbar
; ; https://www.autohotkey.com/boards/viewtopic.php?t=113325
; #Z::HideShowTaskbar()

; HideShowTaskbar() {
;     static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
;     static hide := 0
;     hide := !hide
;     APPBARDATA := Buffer(size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
;     NumPut("UInt", size, APPBARDATA), NumPut("Ptr", WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
;     NumPut("UInt", hide ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
;     DllCall("Shell32\SHAppBarMessage", "UInt", ABM_SETSTATE, "Ptr", APPBARDATA)
; }


; !m::WinMinimize("A")

; !f::Send("{F11}")

; Alt-W and Alt-Q Close Windows
; !w::WinClose("A")
; !q::Send("!{F4}")

; Application Shortcuts
!+Enter::
{
	Run("wezterm-gui.exe")
Return
}

!+c::
{
	Run("chrome.exe")
Return
}

!+e::
{
	Run("msedge.exe")
Return
}

!+Backspace::
{
	ScriptPath := A_ScriptDir "\scripts\Random-Wallpaper.ps1"
	if (A_ComputerName = "Analog") {
		Run("PowerShell.exe -Command `"" ScriptPath " -WallPaperPath C:\Users\eric\Pictures\Wallpaper\5120x1440`"", "A_ScriptDir", "Hide")
	} else {
		Run("PowerShell.exe -Command `"" ScriptPath " -WallPaperPath C:\Users\eric\Pictures\Wallpaper`"", "A_ScriptDir", "Hide")
	}
Return

;^XButton1::
;    Send, ^w
;return
;return

;^XButton2::
;    Send, ^w
;return
;return
} ; V1toV2: Added Bracket before hotkey or Hotstring


^+WheelDown::Send("{Left}")
^+WheelUp::Send("{Right}")
^+MButton::Send("^w")