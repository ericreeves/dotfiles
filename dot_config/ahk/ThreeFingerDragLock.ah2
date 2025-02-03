#Requires AutoHotkey v2.0

; Use AHK v2.0. In Windows set Touchpad settings > Advanced Gestures > Configure three-finger gestures > Tap: Middle mouse button
; Then use this AHK script:

toggle := false

#HotIf toggle
LButton::
{
    Click "Up"
    global toggle
    toggle := false
}
#HotIf

MButton::
{
    global toggle
    toggle := !toggle
    if toggle
        Click "Down"
    else
        Click "Up"
}