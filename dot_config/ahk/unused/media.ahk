;
; Media Player Keyboard Commands
;
; ! Alt + Win + <key>
;
!#h::
    Send, {Media_Prev}
Return

!#l::
    Send, {Media_Next}
Return

!#k::
    Send, {Volume_Up}
Return

!#j::
    Send, {Volume_Down}
Return

!#Space::
    Send, {Media_Play_Pause}
Return

!#m::
    Send, {Volume_Mute}
Return

!+z::
    Send, {Browser_Back}
Return

!+x::
    Send, {Browser_Forward}
Return

!#WheelDown::
    ChangeVolume("-")
return
return

!#WheelUp::
    ChangeVolume("+")
return
return

ChangeVolume(x)
{ 
    SoundGet, vol, Master, Volume
    if (x = "+")
        nd := Round(vol) < 20 ? 2 : 5
    else
        nd := Round(vol) <= 20 ? 2 : 5
    nv = %x%%nd%
    SoundSet, nv, Master, Volume
    SoundSet, 0, Master, Mute
}
