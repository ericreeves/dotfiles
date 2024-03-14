; # Win (Windows logo key)
; ! Alt
; ^ Control
; + Shift
; & An ampersand may be used between any two keys or mouse buttons to combine them into a custom hotkey.
;
; https://www.autohotkey.com/docs/v1/KeyList.htm
;


#Requires AutoHotkey v2.0
#SingleInstance Force

; $CapsLock::Ctrl 

; Application Shortcuts
!+Enter::Run "C:\Users\eric\scoop\apps\wezterm-nightly\current\wezterm-gui.exe"

!+c::Run "chrome.exe"

!+e::Run "msedge.exe"

; ^+WheelDown::
;    Send, {Left}
; return
; return

; ^+WheelUp::
;    Send, {Right}
; return
; return

; ^+MButton::
;    Send, ^w
; return
; return

; +WheelDown::
;    Send, ^{PgUp}
; return
; return

; +WheelUp::
;    Send, ^{PgDn}
; return
; return

; +LButton::
;    Send, {Browser_Back}
; return
; return

; +RButton::
;    Send, {Browser_Forward}
; return
; return
