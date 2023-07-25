;
; FancyZones Layout Cycle (AHKv2)
; 

#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)


; Insert the ID's of the FancyZones Layouts to Cycle (as an array of strings)
arr := ["0", "9", "8", "1", "2", "3", "4", "5", "6", "7"]
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

