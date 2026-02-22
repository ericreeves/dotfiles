#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook True
; #NoTrayIcon

; ----------------------------
; HRM assumptions (Voyager + Kanata)
; Left hand:
;   A = LWin (lmet)   S = LAlt (lalt)   D = LCtrl (lctl)   F = LShift (lsft)
; Right hand:
;   J = RShift (rsft) K = RCtrl (rctl)  L = RAlt (ralt)    ; = RWin (rmet)
;
; We deliberately bind Komorebi to LEFT modifiers so the right-hand mods
; can be reserved for workspace/window selection.
; ----------------------------

global MAX_WS := 4  ; 5 workspaces: 0..4  (aka 1..5 if you think human)


Komorebic(args) {
    Run('komorebic.exe ' args, , "Hide")
}

FocusOrLaunch(exeName, exeOrPath, lnkPath := "") {
    if !WinExist("ahk_exe " exeName) {
        Run(lnkPath != "" ? lnkPath : exeOrPath)
    } else {
        WinActivate("ahk_exe " exeName)
    }
}

; ---------- Hyper (Win+Alt+Ctrl+Shift) app launchers ----------
; Hyper = A+S+D+F with HRMs
; Focus or launch WezTerm (Alt+Win+Ctrl+Shift+T)
!#^+t::FocusOrLaunch("wezterm-gui.exe", "wezterm-gui.exe")
; Focus or launch Vivaldi (Alt+Win+Ctrl+Shift+V)
!#^+v::FocusOrLaunch("vivaldi.exe", "vivaldi.exe")
; Focus or launch Explorer (Alt+Win+Ctrl+Shift+E)
!#^+e::FocusOrLaunch("explorer.exe", "explorer.exe")
; Focus or launch Discord (Alt+Win+Ctrl+Shift+D)
!#^+d::FocusOrLaunch("discord.exe", "discord.exe", "C:\Users\eric\AppData\Local\Discord\Update.exe --processStart Discord.exe")

; Reload komorebi config, retile, and reload AHK script (LAlt+LWin+LCtrl+LShift+/)
!#^+/::{
    Komorebic("reload-configuration")
    Sleep 50
    Komorebic("retile")
    Reload()
}

; ---------- Komorebi WM chord = LeftAlt + LeftWin ----------
; WM = A+S with HRMs (Left Win + Left Alt)


#!g::Komorebic("manage")
#!^g::Komorebic("unmanage")

; Retile windows (RAlt+RWin+T)
!#t::Komorebic("retile")
; Toggle pause (LAlt+LWin+P)
; !#p::Komorebic("toggle-pause")

; Close window (RAlt+RWin+Q)
!#q::Komorebic("close")
#q::Komorebic("close")
; Toggle scrolling columns 1↔2 — niri-style maximize (LAlt+LWin+M)
global scrollCols := 2
!#m::{
    global scrollCols
    scrollCols := (scrollCols = 2) ? 1 : 2
    Komorebic("scrolling-layout-columns " scrollCols)
}

; Focus window left (LAlt+LWin+H)
!#h::Komorebic("focus left")
; Focus window down (LAlt+LWin+J)
!#j::Komorebic("focus down")
; Focus window up (LAlt+LWin+K)
!#k::Komorebic("focus up")
; Focus window right (LAlt+LWin+L)
!#l::Komorebic("focus right")

; Move window left (LAlt+LWin+LCtrl+H)
!#^h::Komorebic("move left")
; Move window down (LAlt+LWin+LCtrl+J)
!#^j::Komorebic("move down")
; Move window up (LAlt+LWin+LCtrl+K)
!#^k::Komorebic("move up")
; Move window right (LAlt+LWin+LCtrl+L)
!#^l::Komorebic("move right")

; Resize horizontal decrease (LAlt+LWin+LShift+H)
!#+h::Komorebic("resize-axis horizontal decrease")
; Resize horizontal increase (LAlt+LWin+LShift+L)
!#+l::Komorebic("resize-axis horizontal increase")
; Resize vertical decrease (LAlt+LWin+LShift+K)
!#+k::Komorebic("resize-axis vertical decrease")
; Resize vertical increase (LAlt+LWin+LShift+J)
!#+j::Komorebic("resize-axis vertical increase")

; Stack window left (LAlt+LWin+LCtrl+LShift+H)
!#^+h::Komorebic("stack left")
; Stack window down (LAlt+LWin+LCtrl+LShift+J)
!#^+j::Komorebic("stack down")
; Stack window up (LAlt+LWin+LCtrl+LShift+K)
!#^+k::Komorebic("stack up")
; Stack window right (LAlt+LWin+LCtrl+LShift+L)
!#^+l::Komorebic("stack right")
; Unstack window (LAlt+LWin+LCtrl+LShift+;)
!#^+;::Komorebic("unstack")
; Promote window (LAlt+LWin+LCtrl+LShift+')
!#^+'::Komorebic("promote")

; Cycle layout previous (LAlt+LWin+,)
!#,::Komorebic("cycle-layout previous")
; Cycle layout next (LAlt+LWin+.)
!#.::Komorebic("cycle-layout next")

; Flip layout horizontal (LAlt+LWin+\)
!#\::Komorebic("flip-layout horizontal")
; Flip layout vertical (LAlt+LWin+/)
!#/::Komorebic("flip-layout vertical")

; Cycle stack previous (LAlt+LWin+U)
!#^u::Komorebic("cycle-stack previous")
; Cycle stack next (LAlt+LWin+I)
!#^i::Komorebic("cycle-stack next")

; Cycle focus previous (LAlt+LWin+Y)
!#u::Komorebic("cycle-focus previous")
; Cycle focus next (LAlt+LWin+O)
!#i::Komorebic("cycle-focus next")

; Cycle workspace previous (LAlt+LWin+LCtrl+U)
!#y::Komorebic("cycle-workspace previous")
; Cycle workspace next (LAlt+LWin+LCtrl+I)
!#o::Komorebic("cycle-workspace next")

; Move window to previous workspace (LAlt+LWin+LCtrl+LShift+U)
!#^y::Komorebic("cycle-move-to-workspace previous")
; Move window to next workspace (LAlt+LWin+LCtrl+LShift+I)
!#^o::Komorebic("cycle-move-to-workspace next")

; Cycle monitor previous (LAlt+LWin+LCtrl+Y)
; !#n::Komorebic("cycle-monitor previous")
; Cycle monitor next (LAlt+LWin+LCtrl+O)
; !#m::Komorebic("cycle-monitor next")

; Move window to previous monitor (LAlt+LWin+LCtrl+LShift+Y)
; !#^n::Komorebic("cycle-move-to-monitor previous")
; Move window to next monitor (LAlt+LWin+LCtrl+LShift+O)
; !#^m::Komorebic("cycle-move-to-monitor next")


; Toggle workspace layer (LAlt+LWin+;)
!#;::Komorebic("toggle-workspace-layer")
; Toggle float (LAlt+LWin+LCtrl;)
!#^;::Komorebic("toggle-float")
; Toggle monocle (LAlt+LWin+LCtrl+LShift+;)
!#^'::Komorebic("toggle-monocle")

; ---------- Workspaces: Right-hand mods ----------
; Focus workspace 1 on monitor 0 (RAlt+RWin+Z)
!#z::Komorebic("focus-monitor-workspace 0 0")
; Focus workspace 2 on monitor 0 (RAlt+RWin+X)
!#x::Komorebic("focus-monitor-workspace 0 1")
; Focus workspace 3 on monitor 0 (RAlt+RWin+C)
!#c::Komorebic("focus-monitor-workspace 0 2")
; Focus workspace 4 on monitor 0 (RAlt+RWin+V)
!#v::Komorebic("focus-monitor-workspace 0 3")
; Focus workspace 5 on monitor 0 (RAlt+RWin+B)
!#b::Komorebic("focus-monitor-workspace 0 4")

; Focus workspace 1 on monitor 0 (RAlt+RWin+1)
!#1::Komorebic("focus-monitor-workspace 0 0")
; Focus workspace 2 on monitor 0 (RAlt+RWin+2)
!#2::Komorebic("focus-monitor-workspace 0 1")
; Focus workspace 3 on monitor 0 (RAlt+RWin+3)
!#3::Komorebic("focus-monitor-workspace 0 2")
; Focus workspace 4 on monitor 0 (RAlt+RWin+4)
!#4::Komorebic("focus-monitor-workspace 0 3")
; Focus workspace 5 on monitor 0 (RAlt+RWin+5)
!#5::Komorebic("focus-monitor-workspace 0 4")

; Move window to workspace 1 on monitor 0 (RAlt+RWin+RShift+Z)
!#^z::Komorebic("move-to-monitor-workspace 0 0")
; Move window to workspace 2 on monitor 0 (RAlt+RWin+RShift+X)
!#^x::Komorebic("move-to-monitor-workspace 0 1")
; Move window to workspace 3 on monitor 0 (RAlt+RWin+RShift+C)
!#^c::Komorebic("move-to-monitor-workspace 0 2")
; Move window to workspace 4 on monitor 0 (RAlt+RWin+RShift+V)
!#^v::Komorebic("move-to-monitor-workspace 0 3")
; Move window to workspace 5 on monitor 0 (RAlt+RWin+RShift+B)
!#^b::Komorebic("move-to-monitor-workspace 0 4")

; Move window to workspace 1 on monitor 0 (RCtrl+RWin+RShift+1)
!#^1::Komorebic("move-to-monitor-workspace 0 0")
; Move window to workspace 2 on monitor 0 (RCtrl+RWin+RShift+2)
!#^2::Komorebic("move-to-monitor-workspace 0 1")
; Move window to workspace 3 on monitor 0 (RCtrl+RWin+RShift+3)
!#^3::Komorebic("move-to-monitor-workspace 0 2")
; Move window to workspace 4 on monitor 0 (RCtrl+RWin+RShift+4)
!#^4::Komorebic("move-to-monitor-workspace 0 3")
; Move window to workspace 5 on monitor 0 (RCtrl+RWin+RShift+5)
!#^5::Komorebic("move-to-monitor-workspace 0 4")
