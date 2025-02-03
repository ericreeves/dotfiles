#Requires AutoHotkey v2.0

; https://www.autohotkey.com/boards/viewtopic.php?t=128659

; ApplicationSwitcher_v2.ahk
; by vysmaty
; version 20240414

; This is a modified script for v2.
; From Taran Van Hemert and … and … fill in your name. I had it too many years and I don't know exact source. It's rewriten.
; https://www.youtube.com/watch?v=OqyQABySV8k

; Icons by https://icons8.com/

; Script for quick switching between applications, application windows, application tabs and application minimization.
; You have to set your MODIFIER KEYS and APPS & KEYS below.

#Requires AutoHotkey v2.0
#SingleInstance force
#WinActivateForce
SendMode("Input")

; MARK: SET your MODIFIER KEYS
;{-----------------------------------------------

; # Win
; ! Alt
; ^ Ctrl
; + Shift
; !^+ MEH
; !^+# HYPER

; Show Gui With Help
HelpHotkey := ["!^+a"] ; Eg. ( Shift+Win OR Left Mouse Button ) + Numpad Minus key

; Switch Between aka Cycle Through Windows
SwitchBetweenKey := ["!^+#"] ; Eg. ( Shift+Win OR Left Mouse Button ) + Key set for app
; Switch to Window and cycle through tabs
; SwitchToKey := ["!^+#"] ; Eg. ( Ctrl+Win) + Key set for app; Or USE Tabs On Wheels ;)
; Minimize Window
; MinimalizeKey := ["^+#"] ; Eg. (Alt+Win) + Key set for app


;{-----------------------------------------------
; Close Window
for Modifier in SwitchBetweenKey
{
  Hotkey(Modifier "Esc", CloseWindow.Bind()) ; Eg. ( Shift+Win OR Left Mouse Button ) + Esc to Close Window
}
CloseWindow(this_hotkey) {
  Send "{LButton up}^w"
  ;WinClose("A")
}
;{-----------------------------------------------
; Show Help
for Modifier in HelpHotkey
{
  Hotkey(Modifier, Show.Bind())
}

; Optional For hiding Modifiers from Help Menu
enable_help_for_modifiers := true

; Create base object.
;{-----------------------------------------------
app := Array()
;{-----------------------------------------------

/*
; TEMPLATEs
;{-----------------------------------------------
app.Push(
  ; App Template
  Map(
    "Key", "F13", ; <- Set ME  | OPTIONAL: IF EMPTY APP WILL BE IGNORED. Base Hotkey Key for App Switching.
    "Name", "Template", ; Name
    "EXE", "template.exe", ; Path to Executable (Full Path or Short from ENV)
    "ID", "ahk_class templates", ; Window Identification (ahk_exe, ahk_class)
    "TabKey", "^{tab}", ; OPTIONAL: Keystroke whitch is Switching Tabs
    "icon", "pathtoicon", ; OPTIONAL: IF EMPTY It try to get it from exe. Icon is used at help menu.
    "ComputerName", "COMPUTERNAME" ;OPTIONAL: IF NOT EMPTY, it will work only on a computer with this name. Must match AHK variable: A_ComputerName. For using same script in sync on multiple machines with different apps/versions.
*/

; MARK: SET Apps and KEYS
;{-----------------------------------------------
; Set the desired last key of shortcut below for each desired app!

; FILE MANAGERs
;{-----------------------------------------------
app.Push(
  ; Windows Explorer
  Map(
    "Key", "e", ; <- Set ME
    "Name", "Explorer",
    "EXE", "explorer.exe",
    "ID", "ahk_class CabinetWClass",
    "TabKey", "^{tab}"
  )
)

; WEB BROWSERS
;{-----------------------------------------------
app.Push(
  ; Chrome
  Map(
    "Key", "b", ; <- Set ME
    "Name", "Chrome",
    "EXE", "chrome.exe",
    "ID", "ahk_exe chrome.exe",
  ;  "icon", ".\icons\Vivaldi.png",
    "TabKey", "^{PgDn}"
  )
)

app.Push(
  Map(
    "Key", "t", ; <- Set ME
    "Name", "Terminal",
    "EXE", "C:\Users\eric\AppData\Local\Microsoft\WindowsApps\wt.exe",
    "ID", "ahk_exe wt.exe",
  ;  "icon", ".\icons\Vivaldi.png",
    ; "TabKey", "^{PgDn}"
  )
)


; NOTES
;{-----------------------------------------------
app.Push(
  ; Notion
  Map(
    "Key", "F10", ; <- Set ME
    "Name", "Notion",
    "EXE", "C:\Users\" A_UserName "\AppData\Local\Programs\Notion\Notion.exe",
    "ID", "ahk_exe Notion.exe",
    "TabKey", "^{tab}"
  )
)

; OFFICE
;{-----------------------------------------------
; Microsoft Office
app.Push(
  Map(
    "Key", "F11", ; <- Set ME
    "Name", "MicrosoftWord",
    "EXE", "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE",
    "ID", "ahk_class OpusApp",
    "icon", ".\icons\Word.png",
    "TabKey", ""
  )
)

; PDF
;{-----------------------------------------------
app.Push(
  ; Foxit PDF Editor
  Map(
    "Key", "F4", ; <- Set ME
    "Name", "FoxitPDFEditor",
    "EXE", "C:\Program Files (x86)\Foxit Software\Foxit PDF Editor\FoxitPDFEditor.exe",
    "ID", "ahk_class classFoxitPhantom",
    "TabKey", "",
    "ComputerName", "BEAST"
  )
)

app.Push(
  ; Foxit PDF Editor
  Map(
    "Key", "F4", ; <- Set ME
    "Name", "FoxitPDFReader",
    "EXE", "C:\Program Files (x86)\Foxit Software\Foxit Reader\C:\Program Files (x86)\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe.exe",
    "ID", "ahk_class classFoxitReader",
    "TabKey", "",
    "ComputerName", "AALTO"
  )
)


; COMUNICATION
;{-----------------------------------------------
; Discord
app.Push(
  Map(
    "Key", "d", ; <- Set ME
    "Name", "Discord",
    "EXE", "C:\Users\" A_UserName "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk",
    "ID", "ahk_exe Discord.exe",
    "TabKey", "^{PgDn}"
  )
)

;{-----------------------------------------------
; Ferdium
app.Push(
  Map(
    "Key", "f", ; <- Set ME
    "Name", "Ferdium",
    "EXE", "C:\Users\" A_UserName "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Ferdium.lnk",
    "ID", "ahk_exe Ferdium.exe",
    "TabKey", "^{PgDn}"
  )
)

;{-----------------------------------------------
; Slasck
app.Push(
  Map(
    "Key", "c", ; <- Set ME
    "Name", "Slack",
    "EXE", "C:\Program Files\Slack\slack.exe",
    "ID", "ahk_exe slack.exe"
  )
)


; CODE
;{-----------------------------------------------
; VSCode
app.Push(
  Map(
    "Key", "v", ; <- Set ME
    "Name", "VSCode",
    "EXE", "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe",
    "ID", "ahk_exe Code.exe",
    "TabKey", "^{PgDn}"
  )
)

app.Push(
  Map(
    "Key", "g", ; <- Set ME
    "Name", "Steam",
    "EXE", "C:\Program Files (x86)\Steam\Steam.exe",
    "ID", "ahk_exe Steam.exe",
  ;  "icon", ".\icons\Vivaldi.png",
    ; "TabKey", "^{PgDn}"
  )
)


; SORT OBJECT NATURALY
; https://en.wikipedia.org/wiki/Natural_sort_order
; Concept of "natural sorting" aka or "human sorting"
; https://ux.stackexchange.com/questions/95431/how-should-sorting-work-when-numeric-is-mixed-with-alpha-numeric


; Sorting Array with Sorted string (by mikeyww)
; https://www.autohotkey.com/boards/viewtopic.php?p=567448&sid=b137a94cd3939b9c6a0648b298b7297b#p567448

app2 := [], sorted := '', regex := '\d+$'
For n, arr in app
  sorted .= (sorted = '' ? '' : '`n') Format('{:-10}{}', arr["Key"], n)
; N at the End is for index from app array.
For line in StrSplit(logical_sort(sorted), '`n')
  ; Sort(sorted) replaced with logical_sort(sorted)
  ; For natural sorting is used external function StrCmpLogicalW
  ; Sort: If option parameter is blank or omitted, String will be sorted in ascending alphabetical order (case-insensitive), using a linefeed (`n) as separator.
  If RegExMatch(line, regex, &m) ; Matching index at the End of line
    app2.Push(app[m[]])

; Output Sorted array
app := app2
app2 := ""

; NATURAL SORTING
; StrCmpLogicalW function
; https://www.autohotkey.com/boards/viewtopic.php?p=320555#p320555

logical_sort(str) {
  return sort(str, , logical_cmp)
  logical_cmp(a, b, o) => dllcall('Shlwapi.dll\StrCmpLogicalW', 'wstr', a, 'wstr', b, 'int')
}

; Help with set keys - popup menu
helpMenu := Menu()
if (enable_help_for_modifiers = true)
{
  ; for Modifier in SwitchBetweenKey {
  ;   item_name := "Cycle Through Windows  :  [" Modifier "]  +"
  ;   helpMenu.Add(item_name, DefaultRun.Bind("notepad.exe " A_ScriptFullPath))
  ;   try {
  ;     helpMenu.SetIcon(item_name, ".\icons\icons8-windows-views-96.png", "1")
  ;   }
  ; }
  ; helpMenu.Add()
  ; for Modifier in SwitchToKey {
  ;   item_name := "Cycle Through Tabs  :  [" Modifier "]  +"
  ;   helpMenu.Add(item_name, DefaultRun.Bind("notepad.exe " A_ScriptFullPath))
  ;   try {
  ;     helpMenu.SetIcon(item_name, ".\icons\icons8-switching-between-tabs-96.png", "1")
  ;   }
  ; }
  ; helpMenu.Add()
  ; for Modifier in MinimalizeKey {
  ;   item_name := "Minimize  :  [" Modifier "]  +"
  ;   helpMenu.Add(item_name, DefaultRun.Bind("notepad.exe " A_ScriptFullPath))
  ;   try {
  ;     helpMenu.SetIcon(item_name, ".\icons\icons8-minimize-96.png", "1")
  ;   }
  ; }
  helpMenu.Add()
}

DefaultRun(command,*)
{
  Run(command)
}

;{-----------------------------------------------
; MARK: Loop Though Apps
;{-----------------------------------------------

; Asign HOTKEYS for All Application and Functions
for k, v in app
{
  if not (v.get("ComputerName", A_ComputerName) = A_ComputerName) {
    continue
  }
  if (v.get("Key", "") = "") {
    continue
  }
  for Modifier in SwitchBetweenKey
  {
    Hotkey(Modifier v["Key"], SwitchBetweenWindows.Bind(, v["ID"], v["Name"], v["EXE"]))
  }
  ; for Modifier in SwitchToKey
  ; {
  ;   Hotkey(Modifier v["Key"], SwitchToWindow.Bind(, v["ID"], v["EXE"], v.get("TabKey", "")))
  ; }
  ; for Modifier in MinimalizeKey
  ; {
  ;   Hotkey(Modifier v["Key"], MinimizeWindow.Bind(, v["ID"]))
  ; }
  item_name := "[" v["Key"] "]   :   " v["Name"]
  helpMenu.Add(item_name, SwitchBetweenWindows.Bind("NONE", v["ID"], v["Name"], v["EXE"]))
 if (v.get("icon", "") != "")
    try {
      helpMenu.SetIcon(item_name, GetFullPathName(v["icon"]), "1")
      continue
    }
  try {
    helpMenu.SetIcon(item_name, v["EXE"], "1")
  }
}

; MARK: Help with generated LIST of Apps and KEYs.
;{-----------------------------------------------
; Show Help
Show(this_hotkey) {
  ;Refresh DarkMode state when menu Called.
  LightTheme := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
  if !LightTheme {
    SetDarkMode()
  }
  helpMenu.Show()
  return
}

; DARKMODE
SetDarkMode() {
  uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
  SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
  FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
  DllCall(SetPreferredAppMode, "int", 1) ; Dark
  DllCall(FlushMenuThemes)
}

; MARK: Functions
;{-----------------------------------------------
; ShellRun runs the given program with restricted privileges as the AutoHotkey
; https://www.autohotkey.com/boards/viewtopic.php?p=404418#p404418
ShellRun(prms*)
{
  shellWindows := ComObject("Shell.Application").Windows
  desktop := shellWindows.FindWindowSW(0, 0, 8, 0, 1) ; SWC_DESKTOP, SWFO_NEEDDISPATCH

  ; Retrieve top-level browser object.
  tlb := ComObjQuery(desktop,
    "{4C96BE40-915C-11CF-99D3-00AA004AE837}", ; SID_STopLevelBrowser
    "{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser

  ; IShellBrowser.QueryActiveShellView -> IShellView
  ComCall(15, tlb, "ptr*", sv := ComValue(13, 0)) ; VT_UNKNOWN

  ; Define IID_IDispatch.
  NumPut("int64", 0x20400, "int64", 0x46000000000000C0, IID_IDispatch := Buffer(16))

  ; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
  ComCall(15, sv, "uint", 0, "ptr", IID_IDispatch, "ptr*", sfvd := ComValue(9, 0)) ; VT_DISPATCH

  ; Get Shell object.
  shell := sfvd.Application

  ; IShellDispatch2.ShellExecute
  shell.ShellExecute(prms*)
}

GetFullPathName(path) {
  ;The GetFullPathName function returns the full path to the file based on the specified relative path. The root against which the relative path is interpreted depends on the current working directory in which the script or program is running.
  cc := DllCall("GetFullPathNameW", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
  buf := Buffer(cc * 2)
  DllCall("GetFullPathNameW", "str", path, "uint", cc, "ptr", buf, "ptr", 0, "uint")
  return StrGet(buf)
}

; SwitchToWindow switches to the last active window matching the given selector
; or starts the program if it is not yet running. If a matching window is
; already active, the given keystroke is sent.
SwitchToWindow(this_hotkey, Selector, FilePath, KeystrokeIfActive := "")
{
  ; Check if a matching window is open
  if !WinExist(Selector)
  {
    ; If not, run the program
    if (FilePath != "")
      ShellRun(FilePath) ; Run the program as a limited user and not as an administrator
    return
  }

  ; Optionally send a keystroke if the window is alredy in focus
  if WinActive(Selector)
  {
    if (KeystrokeIfActive != "`"`"")
      Send(KeystrokeIfActive)
    return
  }

  ; If a window is currently open but not focussed, activate it
  WinActivate()
}

; SwitchBetweenWindows cycles between all windows matching the given selector.
SwitchBetweenWindows(this_hotkey, Selector, GroupIdentifier, FilePath := "", *)
{
  ; Check if a matching window is open
  if WinExist(Selector)
  {
    GroupName := "MacroWindows_" . GroupIdentifier

    ; Add all matching windows to the same group to allow switching between them
    GroupAdd(GroupName, Selector)

    ; Check if a matching window is in already focus
    if WinActive(Selector)
    {
      ; Switch to the next matching window
      GroupActivate(GroupName, "R")
      return
    }

    ; If a window is currently open but not focused, activate it
    WinActivate(Selector)
    return
  }
  else
  {
    ; If not, run the program
    if (FilePath != "")
      ShellRun(FilePath) ; Run the program as a limited user and not as an administrator
    return
  }
  return
}

; MinimizeWindow minimizes the first window matching the given selector.
MinimizeWindow(this_hotkey, Selector)
{
  WinMinimize(Selector)
}