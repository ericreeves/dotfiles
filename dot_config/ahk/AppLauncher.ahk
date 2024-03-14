; # Win (Windows logo key)
; ! Alt
; ^ Control
; + Shift
; & An ampersand may be used between any two keys or mouse buttons to combine them into a custom hotkey.
;
; https://www.autohotkey.com/docs/v1/KeyList.htm
;


#NoEnv
#Persistent
#SingleInstance, force
SetBatchLines, -1
Process, Priority, %PID%, High

SetWorkingDir, %A_ScriptDir%

; $CapsLock::Ctrl 

#s:: Send {PrintScreen}

::zoomlink::https://hashicorp.zoom.us/j/9101845328?pwd=WXRFQ3VJWGdwQWdNRGhxZHAyRXJBUT09

!m::WinMinimize, A

!f::
Send, {F11}
return

; Alt-W and Alt-Q Close Windows
!w:: WinClose A
!q:: Send !{F4}

; Application Shortcuts
!+Enter::
	Run, wezterm-gui.exe
Return

!+c::
	Run, chrome.exe
Return

!+e::
	Run, msedge.exe
Return

!^Backspace::
	; ScriptPath := A_ScriptDir "\scripts\Random-Wallpaper.ps1"
  ScriptPath := "C:\Users\eric\.config\WindowsBox\ahk\scripts\Random-Wallpaper.ps1"
	if (A_ComputerName = "Analog") {
		Run, PowerShell.exe -Command "%ScriptPath% -WallPaperPath C:\Users\eric\OneDrive\Pictures\Wallpaper\5120x1440", A_ScriptDir, Hide
	} else {
		Run, PowerShell.exe -Command "%ScriptPath% -WallPaperPath C:\Users\eric\OneDrive\Pictures\Wallpaper\2880x1800", A_ScriptDir, Hide
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


^+WheelDown::
   Send, {Left}
return
return

^+WheelUp::
   Send, {Right}
return
return

^+MButton::
   Send, ^w
return
return

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


; These macros trigger when Autohotkey detects the Elecom MouseAssist program sending the Japanese keys.
; https://www.reddit.com/r/Trackballs/comments/3zrl8h/elecom_driver_autohotkey_trick/

; 'Convert' Key
; Elecom Button 8 - Track Scroll
; vk1C::WheelLeft

; 'No Convert' Key
; Elecom Buttom 1 - Middle Click
; vk1D::XButton1

; ; Map the Japanese keys to F1-F4 so that you can enter them in the Elecom MouseAssist program.
; F1::
; {
; Send {vk1C} ; Convert
; return
; }

; F2::
; {
; Send {vk1D} ; No Conversion
; return
; }

; F3::
; {
; Send {vk19} ; Half-width/Full-width
; return
; }

; F4::
; {
; Send {vk15} ; Katakana/Hiragana
; return
; }
