#Requires AutoHotkey v2.0

#Include %A_ScriptDir%\F24_CapsLock_Off.ahk
#Include %A_ScriptDir%\Macros.ahk 
#Include %A_ScriptDir%\VD.ahk 

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

