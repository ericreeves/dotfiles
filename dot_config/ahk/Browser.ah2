#Requires AutoHotkey v2.0

#HotIf WinActive("ahk_exe chrome.exe")
+^h::
{
    Keywait("RControl")
    Keywait("RAlt")
    SendEvent("^l")
    SendInput("{left}https://web.archive.org/web/*/{enter}")
}
#HotIf