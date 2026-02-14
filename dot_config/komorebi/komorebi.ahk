#Requires AutoHotkey v2.0
#SingleInstance Force
; #NoTrayIcon

; AutoHotkey v2 Script

; # Win
; ! Alt
; ^ Ctrl
; + Shift

; Reload this script
!o::Reload

; Reload komorebic configuration
!^o::Run("komorebic.exe reload-configuration", , "Hide")

; App shortcuts - focus if open, launch if not
; !f::FocusOrLaunch("Firefox", "firefox.exe")
!^+#b::FocusOrLaunch("Chrome", "chrome.exe")
!^+#t::FocusOrLaunch("wezterm-gui", "wezterm-gui.exe")
!^+#e::FocusOrLaunch("Explorer", "explorer.exe")
!^+#f::FocusOrLaunch("FPilot", "FPilot.exe")

FocusOrLaunch(windowTitle, exePath) {
    if !WinExist(windowTitle) {
        Run(exePath)
    } else {
        WinActivate(windowTitle)
    }
}

;!q::Run("komorebic.exe close", , "Hide")
;!m::Run("komorebic.exe minimize", , "Hide")

^!#u::Run("komorebic.exe unmanage", , "Hide")
^!#m::Run("komorebic.exe manage", , "Hide")

; Focus windows
!#h::Run("komorebic.exe focus left", , "Hide")
!#j::Run("komorebic.exe focus down", , "Hide")
!#k::Run("komorebic.exe focus up", , "Hide")
!#l::Run("komorebic.exe focus right", , "Hide")

; Move windows
!+^#h::Run("komorebic.exe move left", , "Hide")
!+^#j::Run("komorebic.exe move down", , "Hide")
!+^#k::Run("komorebic.exe move up", , "Hide")
!+^#l::Run("komorebic.exe move right", , "Hide")

; Resize
!+l::Run("komorebic.exe resize-axis horizontal increase", , "Hide")
!+h::Run("komorebic.exe resize-axis horizontal decrease", , "Hide")
!+k::Run("komorebic.exe resize-axis vertical increase", , "Hide")
!+j::Run("komorebic.exe resize-axis vertical decrease", , "Hide")

; Stack windows
^#h::Run("komorebic.exe stack left", , "Hide")
^#j::Run("komorebic.exe stack down", , "Hide")
^#k::Run("komorebic.exe stack up", , "Hide")
^#l::Run("komorebic.exe stack right", , "Hide")

;!a::Run("komorebic.exe cycle-focus previous", , "Hide")
;!g::Run("komorebic.exe cycle-focus next", , "Hide")

!^#Enter::Run("komorebic.exe promote", , "Hide")

!;::Run("komorebic.exe unstack", , "Hide") ; SC027 is ;
![::Run("komorebic.exe cycle-focus previous", , "Hide") ; SC01A is [
!]::Run("komorebic.exe cycle-focus next", , "Hide") ; SC01B is ]
!^[::Run("komorebic.exe cycle-stack previous", , "Hide") ; SC01A is [
!^]::Run("komorebic.exe cycle-stack next", , "Hide") ; SC01B is ]


; Manipulate windows
!^f::Run("komorebic.exe toggle-float", , "Hide")
!+f::Run("komorebic.exe toggle-monocle", , "Hide")
!#f::Run("komorebic.exe toggle-workspace-layer", , "Hide")

; Window manager options
!^r::Run("komorebic.exe retile", , "Hide")
!p::Run("komorebic.exe toggle-pause", , "Hide")

; Layouts
;!x::Run("komorebic.exe flip-layout horizontal", , "Hide")
;!y::Run("komorebic.exe flip-layout vertical", , "Hide")

; Workspaces
!#1::Run("komorebic.exe focus-monitor-workspace 0 0", , "Hide")
!#2::Run("komorebic.exe focus-monitor-workspace 0 1", , "Hide")
!#3::Run("komorebic.exe focus-monitor-workspace 0 2", , "Hide")
!#4::Run("komorebic.exe focus-monitor-workspace 0 3", , "Hide")
!#5::Run("komorebic.exe focus-monitor-workspace 0 4", , "Hide")
!#6::Run("komorebic.exe focus-monitor-workspace 1 0", , "Hide")
!#7::Run("komorebic.exe focus-monitor-workspace 1 1", , "Hide")
!#8::Run("komorebic.exe focus-monitor-workspace 1 2", , "Hide")
!#9::Run("komorebic.exe focus-monitor-workspace 1 3", , "Hide")
!#0::Run("komorebic.exe focus-monitor-workspace 1 4", , "Hide")

; Move windows across workspaces
!^#1::Run("komorebic.exe move-to-workspace 0", , "Hide")
!^#2::Run("komorebic.exe move-to-workspace 1", , "Hide")
!^#3::Run("komorebic.exe move-to-workspace 2", , "Hide")
!^#4::Run("komorebic.exe move-to-workspace 3", , "Hide")
!^#5::Run("komorebic.exe move-to-workspace 4", , "Hide")
!^#6::Run("komorebic.exe move-to-workspace 5", , "Hide")
!^#7::Run("komorebic.exe move-to-workspace 6", , "Hide")
!^#8::Run("komorebic.exe move-to-workspace 7", , "Hide")
!^#9::Run("komorebic.exe move-to-workspace 8", , "Hide")
!^#0::Run("komorebic.exe move-to-workspace 9", , "Hide")

; Workspaces (multiple monitors)
^#1::{
    Run("komorebic.exe focus-monitor-workspace 1 0", , "Hide")
    Run("komorebic.exe focus-monitor-workspace 2 0", , "Hide")
}
^#2::{
    Run("komorebic.exe focus-monitor-workspace 1 1", , "Hide")
    Run("komorebic.exe focus-monitor-workspace 2 1", , "Hide")
}
^#3::{
    Run("komorebic.exe focus-monitor-workspace 1 2", , "Hide")
    Run("komorebic.exe focus-monitor-workspace 2 2", , "Hide")
}
^#4::{
    Run("komorebic.exe focus-monitor-workspace 1 3", , "Hide")
    Run("komorebic.exe focus-monitor-workspace 2 3", , "Hide")
}
^#5::{
    Run("komorebic.exe focus-monitor-workspace 1 4", , "Hide")
    Run("komorebic.exe focus-monitor-workspace 2 4", , "Hide")
}
^#6::{
    Run("komorebic.exe focus-monitor-workspace 1 5", , "Hide")
    Run("komorebic.exe focus-monitor-workspace 2 5", , "Hide")
}
^#7::{
    Run("komorebic.exe focus-monitor-workspace 1 6", , "Hide")
    Run("komorebic.exe focus-monitor-workspace 2 6", , "Hide")
}
^#8::{
    Run("komorebic.exe focus-monitor-workspace 1 7", , "Hide")
    Run("komorebic.exe focus-monitor-workspace 2 7", , "Hide")
}
^#9::{
    Run("komorebic.exe focus-monitor-workspace 1 7", , "Hide")
    Run("komorebic.exe focus-monitor-workspace 2 8", , "Hide")
}

!^v::Run("komorebic.exe cycle-move-to-monitor next", , "Hide")
!^b::Run("komorebic.exe cycle-move-to-monitor previous", , "Hide")
