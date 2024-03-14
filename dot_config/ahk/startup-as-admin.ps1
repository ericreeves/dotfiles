# Run the following commands in an Administrator powershell prompt. 
# Be sure to specify the correct path to your desktop_switcher.ahk file. 

Stop-ScheduledTask DesktopSwitcher 
Unregister-ScheduledTask DesktopSwitcher -Confirm:$false
$A = New-ScheduledTaskAction -Execute "$HOME\scoop\apps\nircmd\current\nircmd.exe" -Argument "execmd $HOME\scoop\shims\autohotkey.exe $HOME\.config\ahk\init.ahk"
$T = New-ScheduledTaskTrigger -AtLogon
$P = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
# $S = New-ScheduledTaskSettingsSet -RestartCount:100000 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -Compatibility Win8 -MultipleInstances IgnoreNew -Hidden -StartWhenAvailable
$S = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -Compatibility Win8 -MultipleInstances IgnoreNew -Hidden -StartWhenAvailable
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask DesktopSwitcher -InputObject $D
Start-ScheduledTask DesktopSwitcher 