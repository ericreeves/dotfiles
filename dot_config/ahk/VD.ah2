;you should first Run this, then Read this
;Ctrl + F: jump to #useful stuff

;#SETUP START
#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
#WinActivateForce

ProcessSetPriority "H"

SetWinDelay -1
SetControlDelay -1


;include the library
#Include %A_LineFile%\..\VD\VD.ah2

;#SETUP END

VD.animation_on:=false
VD.createUntil(4) ;create until we have at least 3 VD

return

!^+1::VD.goToDesktopNum(1)
!^+2::VD.goToDesktopNum(2)
!^+3::VD.goToDesktopNum(3)
!^+4::VD.goToDesktopNum(4)
!^+5::VD.goToDesktopNum(5)

!^+#1::VD.MoveWindowToDesktopNum("A",1).follow()
!^+#2::VD.MoveWindowToDesktopNum("A",2).follow()
!^+#3::VD.MoveWindowToDesktopNum("A",3).follow()
!^+#4::VD.MoveWindowToDesktopNum("A",4).follow()
!^+#5::VD.MoveWindowToDesktopNum("A",5).follow()

; ;just move window
; numpad7::VD.MoveWindowToDesktopNum("A",1)
; numpad8::VD.MoveWindowToDesktopNum("A",2)
; numpad9::VD.MoveWindowToDesktopNum("A",3)

; ; wrapping / cycle back to first desktop when at the last
; ^+#left::VD.goToRelativeDesktopNum(-1)
; ^+#right::VD.goToRelativeDesktopNum(+1)

; ; move window to left and follow it
; #!left::VD.MoveWindowToRelativeDesktopNum("A", -1).follow()
; ; move window to right and follow it
; #!right::VD.MoveWindowToRelativeDesktopNum("A", 1).follow()

; ;to come back to this window
; #NumpadMult::{ ;#*
;     VD.goToDesktopOfWindow("VD.ahk examples WinTitle")
;     ; VD.goToDesktopOfWindow("ahk_exe code.exe")
; }

; ;getters and stuff
; f6::{
;     Msgbox VD.getDesktopNumOfWindow("VD.ahk examples WinTitle")
;     ; Msgbox VD.getDesktopNumOfWindow("ahk_exe GitHubDesktop.exe")
; }
; f1::Msgbox VD.getCurrentDesktopNum()
; f2::Msgbox VD.getCount()

; ;Create/Remove Desktop
; !NumpadAdd::VD.createDesktop(true) ;go to newly created
; #NumpadAdd::VD.createDesktop(false) ;don't go to newly created, also the default

; !NumpadSub::VD.removeDesktop(VD.getCurrentDesktopNum())
; #!NumpadSub::VD.removeDesktop(VD.getCount()) ;removes 3rd desktop if there are 3 desktops

; ^+NumpadAdd::VD.createUntil(3) ;create until we have at least 3 VD

; ^+NumpadSub::{
;     VD.createUntil(3) ;create until we have at least 3 VD
;     sleep 1000
;     ;FALLBACK IS ONLY USED IF YOU ARE CURRENTLY ON THAT VD
;     VD.removeDesktop(3, 1)
; }

; ;Pin Window
; numpad0::VD.TogglePinWindow("A")
; ^numpad0::VD.PinWindow("A")
; !numpad0::VD.UnPinWindow("A")
; #numpad0::MsgBox VD.IsWindowPinned("A")

; ;Pin App
; numpadDot::VD.TogglePinApp("A")
; ^numpadDot::VD.PinApp("A")
; !numpadDot::VD.UnPinApp("A")
; #numpadDot::MsgBox VD.IsAppPinned("A")

; f3::Exitapp
