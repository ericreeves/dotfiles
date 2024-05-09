#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

; FancyWM Script for AutoHotkey
; https://www.autohotkey.com
; Use this script to extend FancyWM using AutoHotkey. Below is a list
; of the commands available to you.

; https://www.autohotkey.com/docs/KeyList.htm

; # Win, ! Alt, ^ Ctrl, + Shift

; Move the focused window out of its containing panel.
~!~#Enter::
Run fancywm.exe --action PullWindowUp
return

; Embed the focused window in a panel.
; AltWin ~+ Key
~!~#-::
Run fancywm.exe --action CreateHorizontalPanel
return
~!~#\::
Run fancywm.exe --action CreateVerticalPanel
return
~!~#s::
Run fancywm.exe --action CreateStackPanel
return

; Move the focus to an adjacent window.
; Alt ~+ hjkl
~!h::
Run fancywm.exe --action MoveFocusLeft
return
~!j::
Run fancywm.exe --action MoveFocusDown
return
~!k::
Run fancywm.exe --action MoveFocusUp
return
~!l::
Run fancywm.exe --action MoveFocusRight
return

; Move the focused window.
; AltCtrl ~+ hjkl
~!~^h::
Run fancywm.exe --action MoveLeft
return
~!~^j::
Run fancywm.exe --action MoveDown
return
~!~^k::
Run fancywm.exe --action MoveUp
return
~!~^l::
Run fancywm.exe --action MoveRight
return

; Swap the focused window. 
; AltWin ~+ hjkl
~!~#h::
Run fancywm.exe --action SwapLeft
return
~!~#j::
Run fancywm.exe --action SwapDown
return
~!~#k::
Run fancywm.exe --action SwapUp
return
~!~#l::
Run fancywm.exe --action SwapRight
return

; Change the width/height of the focused window.
~!~+h::
Run fancywm.exe --action DecreaseWidth
return
~!~+j::
Run fancywm.exe --action DecreaseHeight
return
~!~+k::
Run fancywm.exe --action IncreaseHeight
return
~!~+l::
Run fancywm.exe --action IncreaseWidth
return

; Move to the selected virtual desktop and also switch to it.
; CTL ~+ ALT ~+ GUI ~+ Number keys 
; requires the tilde prefix so it fires also when not released
~!~^1::
Run fancywm.exe --action MoveToDesktop1
Run fancywm.exe --action SwitchToDesktop1
return
~!~^2::
Run fancywm.exe --action MoveToDesktop2
Run fancywm.exe --action SwitchToDesktop2
return
~!~^3::
Run fancywm.exe --action MoveToDesktop3
Run fancywm.exe --action SwitchToDesktop3
return
~!~^4::
Run fancywm.exe --action MoveToDesktop4
Run fancywm.exe --action SwitchToDesktop4
return
~!~^5::
Run fancywm.exe --action MoveToDesktop5
Run fancywm.exe --action SwitchToDesktop5
return
~!~^6::
Run fancywm.exe --action MoveToDesktop6
Run fancywm.exe --action SwitchToDesktop6
return
~!~^7::
Run fancywm.exe --action MoveToDesktop7
Run fancywm.exe --action SwitchToDesktop7
return
~!~^8::
Run fancywm.exe --action MoveToDesktop8
Run fancywm.exe --action SwitchToDesktop8
return
~!~^9::
Run fancywm.exe --action MoveToDesktop9
Run fancywm.exe --action SwitchToDesktop9
return

; Switch to the selected virtual desktop.
; MEH ~+ Number keys 
; requires the tilde prefix so it fires also when not released
~!1::
Run fancywm.exe --action SwitchToDesktop1
return
~!2::
Run fancywm.exe --action SwitchToDesktop2
return
~!3::
Run fancywm.exe --action SwitchToDesktop3
return
~!4::
Run fancywm.exe --action SwitchToDesktop4
return
~!5::
Run fancywm.exe --action SwitchToDesktop5
return
~!6::
Run fancywm.exe --action SwitchToDesktop6
return
~!7::
Run fancywm.exe --action SwitchToDesktop7
return
~!8::
Run fancywm.exe --action SwitchToDesktop8
return
~!9::
Run fancywm.exe --action SwitchToDesktop9
return

; Temporarily toggle the window management functionality in FancyWM.
; Run fancywm.exe --action ToggleManager

; Toggle floating mode for the active window.
~!~^f::
Run fancywm.exe --action ToggleFloatingMode
Return

; Manually refresh the window positions.
~!~^r::
Run fancywm.exe --action RefreshWorkspace
return