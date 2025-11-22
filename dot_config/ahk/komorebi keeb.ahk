#Requires AutoHotkey v2.0
#SingleInstance Force
; #NoTrayIcon

; AutoHotkey v2 Script

; # Win
; ! Alt
; ^ Ctrl
; + Shift

; Reload this script and komorebic configuration
!^+#o::{
    ; RunWait("komorebic.exe reload-configuration", , "Hide")
    Reload()
    ; Run("komorebic.exe retile", , "Hide")
}

; App shortcuts - focus if open, launch if not
; !f::FocusOrLaunch("Firefox", "firefox.exe")
; !^+#b::FocusOrLaunch("brave.exe", "brave.exe")
; !^+#c::FocusOrLaunch("chrome.exe", "chrome.exe")
; !^+#v::FocusOrLaunch("vivaldi.exe", "vivaldi.exe")
; !^+#t::FocusOrLaunch("wezterm-gui.exe", "wezterm-gui.exe")
; !^+#e::FocusOrLaunch("Explorer", "explorer.exe")
; !^+#f::FocusOrLaunch("FPilot.exe", "FPilot.exe")
; !^+#e::FocusOrLaunch("Code.exe", "C:\Users\eric\AppData\Local\Programs\Microsoft VS Code\Code.exe")
; !^+#d::FocusOrLaunch("discord.exe", "discord.exe", "C:\Users\eric\AppData\Local\Discord\Update.exe --processStart Discord.exe")

; Window manager options
!#t::Run("komorebic.exe retile", , "Hide")

; Cycle Layouts
!^+#,::Run("komorebic.exe cycle-layout next", , "Hide")
!^+#.::Run("komorebic.exe cycle-layout previous", , "Hide")

; Layouts
!^+#;::Run("komorebic.exe flip-layout horizontal", , "Hide")
!^+#/::Run("komorebic.exe flip-layout vertical", , "Hide")

!^+#p::Run("komorebic.exe toggle-pause", , "Hide")

; FocusOrLaunch: exeName is the executable name (e.g., "chrome.exe"), exeOrPath is either an executable name or a full path.
FocusOrLaunch(exeName, exeOrPath, lnkPath := "") {
    if !WinExist("ahk_exe " exeName) {
        Run(lnkPath != "" ? lnkPath : exeOrPath)
    } else {
        WinActivate("ahk_exe " exeName)
    }
}

;!q::Run("komorebic.exe close", , "Hide")
;!m::Run("komorebic.exe minimize", , "Hide")

;^!#u::Run("komorebic.exe unmanage", , "Hide")
;^!#m::Run("komorebic.exe manage", , "Hide")

; Focus windows
#!h::Run("komorebic.exe focus left", , "Hide")
#!j::Run("komorebic.exe focus down", , "Hide")
#!k::Run("komorebic.exe focus up", , "Hide")
#!l::Run("komorebic.exe focus right", , "Hide")

#!'::Run("komorebic.exe toggle-lock", , "Hide")
#!,::Run("komorebic.exe cycle-stack previous", , "Hide")
#!.::Run("komorebic.exe cycle-stack next", , "Hide")
#!/::Run("komorebic.exe unstack", , "Hide")
#!;::Run("komorebic.exe promote", , "Hide")

; Move windows
#^h::Run("komorebic.exe move left", , "Hide")
#^j::Run("komorebic.exe move down", , "Hide")
#^k::Run("komorebic.exe move up", , "Hide")
#^l::Run("komorebic.exe move right", , "Hide")
#^.::Run("komorebic.exe cycle-move-to-monitor next", , "Hide")
#^,::Run("komorebic.exe cycle-move-to-monitor previous", , "Hide")
; Manipulate windows
#^;::Run("komorebic.exe toggle-workspace-layer", , "Hide")
#^'::Run("komorebic.exe toggle-float", , "Hide")
#^m::Run("komorebic.exe toggle-monocle", , "Hide")

; Stack windows
#+h::Run("komorebic.exe stack left", , "Hide")
#+j::Run("komorebic.exe stack down", , "Hide")
#+k::Run("komorebic.exe stack up", , "Hide")
#+l::Run("komorebic.exe stack right", , "Hide")
#+;::Run("komorebic.exe unstack", , "Hide")
#+,::Run("komorebic.exe cycle-stack previous", , "Hide")
#+.::Run("komorebic.exe cycle-stack next", , "Hide")

; Resize
^!+l::Run("komorebic.exe resize-axis horizontal increase", , "Hide")
^!+h::Run("komorebic.exe resize-axis horizontal decrease", , "Hide")
^!+k::Run("komorebic.exe resize-axis vertical increase", , "Hide")
^!+j::Run("komorebic.exe resize-axis vertical decrease", , "Hide")

; ![::Run("komorebic.exe cycle-focus previous", , "Hide") ; SC01A is [
; !]::Run("komorebic.exe cycle-focus next", , "Hide") ; SC01B is ]

; Workspaces
#!a::Run("komorebic.exe focus-monitor-workspace 0 0", , "Hide")
#!s::Run("komorebic.exe focus-monitor-workspace 0 1", , "Hide")
#!d::Run("komorebic.exe focus-monitor-workspace 0 2", , "Hide")
#!f::Run("komorebic.exe focus-monitor-workspace 0 3", , "Hide")
#!g::Run("komorebic.exe focus-monitor-workspace 0 4", , "Hide")
; !#6::Run("komorebic.exe focus-monitor-workspace 1 0", , "Hide")
; !#7::Run("komorebic.exe focus-monitor-workspace 1 1", , "Hide")
; !#8::Run("komorebic.exe focus-monitor-workspace 1 2", , "Hide")
; !#9::Run("komorebic.exe focus-monitor-workspace 1 3", , "Hide")
; !#0::Run("komorebic.exe focus-monitor-workspace 1 4", , "Hide")

; Move windows across workspaces
#!^a::Run("komorebic.exe move-to-monitor-workspace 0 0", , "Hide")
#!^s::Run("komorebic.exe move-to-monitor-workspace 0 1", , "Hide")
#!^d::Run("komorebic.exe move-to-monitor-workspace 0 2", , "Hide")
#!^f::Run("komorebic.exe move-to-monitor-workspace 0 3", , "Hide")
#!^g::Run("komorebic.exe move-to-monitor-workspace 0 4", , "Hide")
; ^#6::Run("komorebic.exe move-to-monitor-workspace 1 0", , "Hide")
; ^#7::Run("komorebic.exe move-to-monitor-workspace 1 1", , "Hide")
; ^#8::Run("komorebic.exe move-to-monitor-workspace 1 2", , "Hide")
; ^#9::Run("komorebic.exe move-to-monitor-workspace 1 3", , "Hide")
; ^#0::Run("komorebic.exe move-to-monitor-workspace 1 4", , "Hide")


; Workspaces (multiple monitors)
; ^#1::{
;     Run("komorebic.exe focus-monitor-workspace 1 0", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 0", , "Hide")
; }
; ^#2::{
;     Run("komorebic.exe focus-monitor-workspace 1 1", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 1", , "Hide")
; }
; ^#3::{
;     Run("komorebic.exe focus-monitor-workspace 1 2", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 2", , "Hide")
; }
; ^#4::{
;     Run("komorebic.exe focus-monitor-workspace 1 3", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 3", , "Hide")
; }
; ^#5::{
;     Run("komorebic.exe focus-monitor-workspace 1 4", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 4", , "Hide")
; }
; ^#6::{
;     Run("komorebic.exe focus-monitor-workspace 1 5", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 5", , "Hide")
; }
; ^#7::{
;     Run("komorebic.exe focus-monitor-workspace 1 6", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 6", , "Hide")
; }
; ^#8::{
;     Run("komorebic.exe focus-monitor-workspace 1 7", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 7", , "Hide")
; }
; ^#9::{
;     Run("komorebic.exe focus-monitor-workspace 1 8", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 8", , "Hide")
; }
; ^#0::{
;     Run("komorebic.exe focus-monitor-workspace 1 9", , "Hide")
;     Run("komorebic.exe focus-monitor-workspace 2 9", , "Hide")
; }


