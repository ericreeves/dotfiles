#Requires AutoHotkey v2.0.2
#SingleInstance Force

Komorebic(cmd) {
    RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

; https://www.autohotkey.com/docs/v2/Hotkeys.htm
; https://www.autohotkey.com/docs/v2/KeyList.htm
; # win
; ! alt
; ^ control
; + shift

; !q::Komorebic("close")
!#m::Komorebic("minimize")

; Focus windows
!#j::Komorebic("focus down")
!#h::Komorebic("focus left")
!#k::Komorebic("focus up")
!#l::Komorebic("focus right")

; !a::Komorebic("cycle-focus previous")
; !g::Komorebic("cycle-focus next")
; Move windows

!#+h::Komorebic("move left")
!#+j::Komorebic("move down")
!#+l::Komorebic("move right")
!#+k::Komorebic("move up")
!#+Enter::Komorebic("promote")
!#^m::Komorebic("manage")
!#^u::Komorebic("unmanage")


; Stack windows
!#Left::Komorebic("stack left")
!#Down::Komorebic("stack down")
!#Up::Komorebic("stack up")
!#Right::Komorebic("stack right")
!#;::Komorebic("unstack")
; ![::Komorebic("cycle-stack previous")
; !]::Komorebic("cycle-stack next")

; Resize
!#-::Komorebic("resize-axis horizontal decrease")
!#=::Komorebic("resize-axis horizontal increase")
!#^=::Komorebic("resize-axis vertical increase")
!#^-::Komorebic("resize-axis vertical decrease")

; Manipulate windows
!#^f::Komorebic("toggle-float")
!#f::Komorebic("toggle-workspace-layer")
^#f::Komorebic("toggle-monocle")

; Window manager options
!#^r::Komorebic("retile")
#a::Komorebic("toggle-pause")

; Layouts
!#x::Komorebic("flip-layout horizontal")
!#y::Komorebic("flip-layout vertical")

; Workspaces - Monitor 0
!#1::Komorebic("focus-monitor-workspace 0 0")
!#2::Komorebic("focus-monitor-workspace 0 1")
!#3::Komorebic("focus-monitor-workspace 0 2")
!#4::Komorebic("focus-monitor-workspace 0 3")
!#5::Komorebic("focus-monitor-workspace 0 4")

; Workspaces - Monitor 1
!#+1::Komorebic("focus-monitor-workspace 1 0")
!#+2::Komorebic("focus-monitor-workspace 1 1")
!#+3::Komorebic("focus-monitor-workspace 1 2")
!#+4::Komorebic("focus-monitor-workspace 1 3")
!#+5::Komorebic("focus-monitor-workspace 1 4")

; Move windows across workspaces
!#^1::Komorebic("move-to-workspace 0")
!#^2::Komorebic("move-to-workspace 1")
!#^3::Komorebic("move-to-workspace 2")
!#^4::Komorebic("move-to-workspace 3")
!#^5::Komorebic("move-to-workspace 4")

!^b::Komorebic("cycle-send-to-monitor next")
