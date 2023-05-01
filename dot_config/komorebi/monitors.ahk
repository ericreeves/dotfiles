; This is a working script that displays info about each monitor:
MonitorGetCount, MonitorCount
MonitorGetPrimary, MonitorPrimary
MsgBox, Monitor Count:`t%MonitorCount%`nPrimary Monitor:`t%MonitorPrimary%
Loop, MonitorCount
{
    MonitorGetName, MonitorName, %A_Index%
    MonitorGet, %A_Index%, L, T, R, B
    MonitorGetWorkArea, %A_Index%, WL, WT, WR, WB
    MsgBox, Monitor:`t#%A_Index%`nName:`t%MonitorName%`nLeft:`t%L% (%WL% work)`nTop:`t%T% (%WT% work)`nRight:`t%R% (%WR% work)`nBottom:`t%B% (%WB% work)
}
