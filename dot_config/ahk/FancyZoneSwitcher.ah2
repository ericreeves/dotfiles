;
; FancyZones Layout Cycle (AHKv2)
; 
; # Win (Windows logo key)
; ! Alt
; ^ Control
; + Shift
; & An ampersand may be used between any two keys or mouse buttons to combine them into a custom hotkey.; # Win (Windows logo key)

#Requires AutoHotkey v2.0

#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)


; Insert the ID's of the FancyZones Layouts to Cycle (as an array of strings)
arr := ["1", "2", "3"]
idx := 0

; Cycle Forward through Layouts
!x::
{
  global idx += 1
  if ( idx > (arr.Length - 1))
      global idx := 1
  SendInput("^!#{" arr[idx] "}")
  return
}

; Cycle Backward through Layouts
!z::
{
  global idx -= 1
  if (idx < 1)
      global idx := (arr.Length - 1)
  SendInput("^!#{" arr[idx] "}")
  return
}

