#SingleInstance Force

; Load library
#Include %A_ScriptDir%\komorebic.lib.ahk
; Load configuration
#Include %A_ScriptDir%\komorebi.generated.ahk

workspaceCount := 9


; Function to list workspaces given a count
ArrayFromZero(Length){
  temp := []
  Loop Length {
    temp.Push(A_Index-1)
  }
  return temp
}

; Set workspaces (start from 0)
; ArrayFromZero(9) => [0,1,2,3,4,5,6,7,8]
global workspaces := ArrayFromZero(workspaceCount)

; SysGet 80 == SM_CMONITORS - https://www.autohotkey.com/docs/v2/lib/SysGet.htm
monitorCount := SysGet(80)

init(){
  ; Send the ALT key whenever changing focus to force focus changes
  AltFocusHack("enable")
  ; Default to cloaking windows when switching workspaces
  WindowHidingBehaviour("hide")
  ; Set cross-monitor move behaviour to insert instead of swap
  CrossMonitorMoveBehaviour("Insert")
  ; Enable hot reloading of changes to this file
  WatchConfiguration("enable")

  ; Create named workspaces I-V on monitor 0
  EnsureNamedWorkspaces(0, "1 2 3 4 5 6 7 8 9")
  ; You can do the same thing for secondary monitors too
  EnsureNamedWorkspaces(1, "A B C D E F G H I")

  ; Assign layouts to workspaces, possible values: bsp, columns, rows, vertical-stack, horizontal-stack, ultrawide-vertical-stack
  ; NamedWorkspaceLayout("1", "ultrawide-vertical-stack")
  ; NamedWorkspaceLayout("2", "ultrawide-vertical-stack")
  ; NamedWorkspaceLayout("3", "ultrawide-vertical-stack")
  ; NamedWorkspaceLayout("4", "ultrawide-vertical-stack")

  Loop(monitorCount) {
    monitorIndex := A_Index - 1
    EnsureWorkspaces(monitorIndex, workspaceCount)
    Loop(workspaceCount) {
      workspaceIndex := A_Index - 1
      ContainerPadding(monitorIndex, workspaceIndex, 5)
      WorkspacePadding(monitorIndex, workspaceIndex, 5)
      ; WorkspaceCustomLayout(monitorIndex, workspaceIndex, "C:\Users\eric\.config\komorebi\eric.json")
      WorkspaceLayout(monitorIndex, workspaceIndex, "ultrawide-vertical-stack")
    }
  }

  ; Set the gaps around the edge of the screen for a workspace
  ; NamedWorkspacePadding("I", 0)
  ; Set the gaps between the containers for a workspace
  ; NamedWorkspaceContainerPadding("I", 0)


  ; You can assign specific apps to named workspaces
  ; NamedWorkspaceRule("exe", "Firefox.exe", "III")

  ; Configure the invisible border dimensions
  InvisibleBorders(7, 0, 14, 7)

  ; Uncomment the next lines if you want a visual border around the active window
  ActiveWindowBorder("disable")
  ActiveWindowBorderColour(66, 165, 245, "single")
  ActiveWindowBorderColour(256, 165, 66, "stack")
  ActiveWindowBorderColour(255, 51, 153, "monocle")
  ActiveWindowBorderWidth(3)

  CompleteConfiguration()
}

init()

; Focus windows
!h::Focus("left")
!j::Focus("down")
!k::Focus("up")
!l::Focus("right")
!+[::CycleFocus("previous")
!+]::CycleFocus("next")

; Move windows
!^h::Move("left")
!^j::Move("down")
!^k::Move("up")
!^l::Move("right")
!^Enter::Promote()

; Stack windows
!^u::Stack("left")
!^p::Stack("right")
!^o::Stack("up")
!^i::Stack("down")
!^y::Unstack()
![::CycleStack("previous")
!]::CycleStack("next")

; Resize
!f::ResizeAxis("horizontal", "increase")
!s::ResizeAxis("horizontal", "decrease")
!e::ResizeAxis("vertical", "increase")
!d::ResizeAxis("vertical", "decrease")

; Manipulate windows
!t::ToggleFloat()
!+f::ToggleMonocle()

; Window manager options
!+r::Retile()
!^;::TogglePause()

!o::ReloadConfiguration()

; Layouts
!x::FlipLayout("horizontal")
!y::FlipLayout("vertical")

; Switch to workspace
; Alt + 1~9
; Equal to bind key !1 to !9 to workspace 0 ~ 8
For ws in workspaces {
  Hotkey("!" . (ws+1), (key) => Run("komorebic focus-workspace " . Integer(SubStr(key, 2))-1, ,"Hide"))
  Hotkey("!^" . (ws+1), (key) => Run("komorebic move-to-workspace " . Integer(SubStr(key, 3))-1, ,"Hide"))
}

;; Get Window Info
;; Helpful for debugging
!+m::{
  window_id := ""
  MouseGetPos(,,&window_id)
  window_title := WinGetTitle(window_id)
  window_class := WinGetClass(window_id)
  MsgBox(window_id "`n" window_class "`n" window_title)
}

; Workspaces
; !1::FocusWorkspace(0)
; !2::FocusWorkspace(1)
; !3::FocusWorkspace(2)
; !4::FocusWorkspace(3)
; !5::FocusWorkspace(4)
; !6::FocusWorkspace(5)
; !7::FocusWorkspace(6)
; !8::FocusWorkspace(7)
; !9::FocusWorkspace(8)

; Move windows across workspaces
; !^1::MoveToWorkspace(0)
; !^2::MoveToWorkspace(1)
; !^3::MoveToWorkspace(2)
; !^4::MoveToWorkspace(3)
; !^5::MoveToWorkspace(4)
; !^6::MoveToWorkspace(5)
; !^7::MoveToWorkspace(6)
; !^8::MoveToWorkspace(7)
; !^9::MoveToWorkspace(8)

; Close application; Alt + Q
;!q::Send "!{F4}"
!q::WinClose("A")

;; Restart komorebi in a hard way
!^q::{
  RunWait("komorebic restore-windows",,"Hide")
  RunWait("powershell " . "Stop-Process -Name 'komorebi'",,"Hide")
  RunWait("komorebic start") ;; intend to not hide it
  ;; Delay 1000 milisecond
  Sleep(1000)
  init()
}

!Enter::Run("wezterm-gui")
