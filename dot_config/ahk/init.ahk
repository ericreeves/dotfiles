#Requires AutoHotkey v2.0
#SingleInstance Force

#Include %A_ScriptDir%\F24_CapsLock_Off.ahk
#Include %A_ScriptDir%\Macros.ahk 
; #Include %A_ScriptDir%\VD.ahk 
#Include %A_ScriptDir%\komorebi.ahk 

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

; Hide desktop icons with Win + Alt + D
#HotIf WinActive("ahk_class Progman") || WinActive("ahk_class WorkerW")
#!d::DesktopIcons()
#HotIf

DesktopIcons(){
  hProgman:=WinExist("ahk_class WorkerW","FolderView")?WinExist():WinExist("ahk_class Progman","FolderView")
  hShellDefView:=DllCall("user32.dll\GetWindow","ptr",hProgman,"int",5,"ptr")
  hSysListView:=DllCall("user32.dll\GetWindow","ptr",hShellDefView,"int",5,"ptr")
  If (DllCall("user32.dll\IsWindowVisible","ptr",hSysListView)!=-1)
    DllCall("user32.dll\SendMessage","ptr",hShellDefView,"ptr",0x111,"ptr",0x7402,"ptr",0)
}

; Win + Enter Terminal
; #Enter::Run("wt.exe")

