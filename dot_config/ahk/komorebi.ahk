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


Komo(args) {
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
<!<#<^<+/::{
    Komo("reload-configuration")
    Sleep 50
    Komo("retile")
    Reload()
}

; ---------- Komorebi WM chord = LeftAlt + LeftWin ----------
; WM = A+S with HRMs (Left Win + Left Alt)


>#>!g::Komo("manage")
>#>!>^g::Komo("unmanage")

; Retile windows (RAlt+RWin+T)
>!>#t::Komo("retile")
; Toggle pause (LAlt+LWin+P)
; <!<#p::Komo("toggle-pause")

; Close window (RAlt+RWin+Q)
>!>#q::Komo("close")
; Minimize window (LAlt+LWin+M)
; <!<#m::Komo("minimize")

; Focus window left (LAlt+LWin+H)
<!<#h::Komo("focus left")
; Focus window down (LAlt+LWin+J)
<!<#j::Komo("focus down")
; Focus window up (LAlt+LWin+K)
<!<#k::Komo("focus up")
; Focus window right (LAlt+LWin+L)
<!<#l::Komo("focus right")

; Move window left (LAlt+LWin+LCtrl+H)
<!<#<^h::Komo("move left")
; Move window down (LAlt+LWin+LCtrl+J)
<!<#<^j::Komo("move down")
; Move window up (LAlt+LWin+LCtrl+K)
<!<#<^k::Komo("move up")
; Move window right (LAlt+LWin+LCtrl+L)
<!<#<^l::Komo("move right")

; Resize horizontal decrease (LAlt+LWin+LShift+H)
<!<#<+h::Komo("resize-axis horizontal decrease")
; Resize horizontal increase (LAlt+LWin+LShift+L)
<!<#<+l::Komo("resize-axis horizontal increase")
; Resize vertical decrease (LAlt+LWin+LShift+K)
<!<#<+k::Komo("resize-axis vertical decrease")
; Resize vertical increase (LAlt+LWin+LShift+J)
<!<#<+j::Komo("resize-axis vertical increase")

; Stack window left (LAlt+LWin+LCtrl+LShift+H)
<!<#<^<+h::Komo("stack left")
; Stack window down (LAlt+LWin+LCtrl+LShift+J)
<!<#<^<+j::Komo("stack down")
; Stack window up (LAlt+LWin+LCtrl+LShift+K)
<!<#<^<+k::Komo("stack up")
; Stack window right (LAlt+LWin+LCtrl+LShift+L)
<!<#<^<+l::Komo("stack right")
; Unstack window (LAlt+LWin+LCtrl+LShift+;)
<!<#<^<+;::Komo("unstack")
; Promote window (LAlt+LWin+LCtrl+LShift+')
<!<#<^<+'::Komo("promote")

; Cycle layout previous (LAlt+LWin+,)
<!<#,::Komo("cycle-layout previous")
; Cycle layout next (LAlt+LWin+.)
<!<#.::Komo("cycle-layout next")

; Flip layout horizontal (LAlt+LWin+\)
<!<#\::Komo("flip-layout horizontal")
; Flip layout vertical (LAlt+LWin+/)
<!<#/::Komo("flip-layout vertical")

; Cycle stack previous (LAlt+LWin+U)
<!<#<^u::Komo("cycle-stack previous")
; Cycle stack next (LAlt+LWin+I)
<!<#<^i::Komo("cycle-stack next")

; Cycle focus previous (LAlt+LWin+Y)
<!<#u::Komo("cycle-focus previous")
; Cycle focus next (LAlt+LWin+O)
<!<#i::Komo("cycle-focus next")

; Cycle workspace previous (LAlt+LWin+LCtrl+U)
<!<#y::Komo("cycle-workspace previous")
; Cycle workspace next (LAlt+LWin+LCtrl+I)
<!<#o::Komo("cycle-workspace next")

; Move window to previous workspace (LAlt+LWin+LCtrl+LShift+U)
<!<#<^y::Komo("cycle-move-to-workspace previous")
; Move window to next workspace (LAlt+LWin+LCtrl+LShift+I)
<!<#<^o::Komo("cycle-move-to-workspace next")

; Cycle monitor previous (LAlt+LWin+LCtrl+Y)
<!<#n::Komo("cycle-monitor previous")
; Cycle monitor next (LAlt+LWin+LCtrl+O)
<!<#m::Komo("cycle-monitor next")

; Move window to previous monitor (LAlt+LWin+LCtrl+LShift+Y)
<!<#<^n::Komo("cycle-move-to-monitor previous")
; Move window to next monitor (LAlt+LWin+LCtrl+LShift+O)
<!<#<^m::Komo("cycle-move-to-monitor next")


; Toggle workspace layer (LAlt+LWin+;)
<!<#;::Komo("toggle-workspace-layer")
; Toggle float (LAlt+LWin+LCtrl;)
<!<#<^;::Komo("toggle-float")
; Toggle monocle (LAlt+LWin+LCtrl+LShift+;)
<!<#<^'::Komo("toggle-monocle")

; ---------- Workspaces: Right-hand mods ----------
; Focus workspace 1 on monitor 0 (RAlt+RWin+Z)
>!>#z::Komo("focus-monitor-workspace 0 0")
; Focus workspace 2 on monitor 0 (RAlt+RWin+X)
>!>#x::Komo("focus-monitor-workspace 0 1")
; Focus workspace 3 on monitor 0 (RAlt+RWin+C)
>!>#c::Komo("focus-monitor-workspace 0 2")
; Focus workspace 4 on monitor 0 (RAlt+RWin+V)
>!>#v::Komo("focus-monitor-workspace 0 3")
; Focus workspace 5 on monitor 0 (RAlt+RWin+B)
>!>#b::Komo("focus-monitor-workspace 0 4")

; Focus workspace 1 on monitor 0 (RAlt+RWin+1)
>!>#1::Komo("focus-monitor-workspace 0 0")
; Focus workspace 2 on monitor 0 (RAlt+RWin+2)
>!>#2::Komo("focus-monitor-workspace 0 1")
; Focus workspace 3 on monitor 0 (RAlt+RWin+3)
>!>#3::Komo("focus-monitor-workspace 0 2")
; Focus workspace 4 on monitor 0 (RAlt+RWin+4)
>!>#4::Komo("focus-monitor-workspace 0 3")
; Focus workspace 5 on monitor 0 (RAlt+RWin+5)
>!>#5::Komo("focus-monitor-workspace 0 4")

; Move window to workspace 1 on monitor 0 (RAlt+RWin+RShift+Z)
>!>#>^z::Komo("move-to-monitor-workspace 0 0")
; Move window to workspace 2 on monitor 0 (RAlt+RWin+RShift+X)
>!>#>^x::Komo("move-to-monitor-workspace 0 1")
; Move window to workspace 3 on monitor 0 (RAlt+RWin+RShift+C)
>!>#>^c::Komo("move-to-monitor-workspace 0 2")
; Move window to workspace 4 on monitor 0 (RAlt+RWin+RShift+V)
>!>#>^v::Komo("move-to-monitor-workspace 0 3")
; Move window to workspace 5 on monitor 0 (RAlt+RWin+RShift+B)
>!>#>^b::Komo("move-to-monitor-workspace 0 4")

; Move window to workspace 1 on monitor 0 (RCtrl+RWin+RShift+1)
>!>#>^1::Komo("move-to-monitor-workspace 0 0")
; Move window to workspace 2 on monitor 0 (RCtrl+RWin+RShift+2)
>!>#>^2::Komo("move-to-monitor-workspace 0 1")
; Move window to workspace 3 on monitor 0 (RCtrl+RWin+RShift+3)
>!>#>^3::Komo("move-to-monitor-workspace 0 2")
; Move window to workspace 4 on monitor 0 (RCtrl+RWin+RShift+4)
>!>#>^4::Komo("move-to-monitor-workspace 0 3")
; Move window to workspace 5 on monitor 0 (RCtrl+RWin+RShift+5)
>!>#>^5::Komo("move-to-monitor-workspace 0 4")
