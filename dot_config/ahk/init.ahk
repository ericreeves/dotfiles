#Requires AutoHotkey v2.0

; #Include %A_ScriptDir%\AppLauncher_newV2.ahk
#Include %A_ScriptDir%\ActiveBorder.ahk
; #Include %A_ScriptDir%\FancyZoneSwitcher.ahk
#Include %A_ScriptDir%\VirtualDesktopAccessor.ah2
#Include %A_ScriptDir%\F24_CapsLock_Off.ahk

+^A::WinMove(1280,0,2560,1440,'A')
+^D::Send("edd{Tab}{Tab}{Tab}{Tab}{Enter}")