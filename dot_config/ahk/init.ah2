#Requires AutoHotkey v2.0

; #Include %A_ScriptDir%\ActiveBorder.ah2
#Include %A_ScriptDir%\F24_CapsLock_Off.ah2
; #Include %A_ScriptDir%\ThreeFingerDragLock.ah2
#Include %A_ScriptDir%\Browser.ah2
#Include %A_ScriptDir%\AppLauncher.ah2

#Include %A_ScriptDir%\VirtualDesktopAccessor.ah2
; #Include %A_ScriptDir%\VD.ah

+^A::WinMove(1280,0,2560,1440,'A')
+^D::Send("edd{Tab}{Tab}{Tab}{Tab}{Enter}")

; Win+\
#\::
{
    SendMessage(0x112, 0xF140, 0, , "Program Manager")  ; Start screensaver
    SendMessage(0x112, 0xF170, 2, , "Program Manager")  ; Monitor off
}

; Win+;
#;::
{
    Run("rundll32.exe user32.dll,LockWorkStation")      ; Lock PC
    Sleep(1000)
    SendMessage(0x112, 0xF170, 2, , "Program Manager")  ; Monitor off
}

!^+#r::Reload
