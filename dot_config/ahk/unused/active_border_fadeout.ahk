;
; Inspiration / Code Jacked from the following resources:
; https://www.reddit.com/r/windowsporn/comments/x6299x/a_small_effect_on_window_switching/
; https://superuser.com/questions/1190658/fine-tune-this-red-border-around-active-window-ahk-script/1191059#1191059?newreg=d3acdcdab8714e76a5efeca9996e792f
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=110505
; https://discord.com/channels/898554690126630914/898556726108901386/1053662963585781760  # Komorebi Discord
;

#NoEnv
#SingleInstance, Force
#Persistent
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
border_color :=  0x89B4FA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Gui +LastFound
hWnd := WinExist()

DllCall("RegisterShellHookWindow", UInt,hWnd)
MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
OnMessage(MsgNum, "ShellMessage")
Return

ShellMessage(wParam,lParam) {
    Local k
    if (wParam = 32772){
        SetTimer, DrawActive, -1
    }
}

DrawActive:
    ; Start by removing the borders from all windows, since we do not know which window was previously active
    WinGet, WindowHandles, List
    loop % WindowHandles
    {
        DrawBorder(WindowHandles%A_Index%, %border_color%, 0)
    }
    ; Draw the border around the active window
    hwnd := WinExist("A")
    DrawBorder(hwnd, %border_color%, 1)
Return

DrawBorder(hwnd, color:=0xFF0000, enable:=1) {
    static DWMWA_BORDER_COLOR := 34
    static DWMWA_COLOR_DEFAULT	:= 0xFFFFFFFF
    R := (color & 0xFF0000) >> 16
    G := (color & 0xFF00) >> 8
    B := (color & 0xFF)
    color := (B << 16) | (G << 8) | R
    DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_BORDER_COLOR, "int*", enable ? color : DWMWA_COLOR_DEFAULT, "int", 4)
}