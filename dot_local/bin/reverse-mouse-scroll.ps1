# Set mode to 1 for reverse scroll, 0 for normal scroll
$mode = 1;
Get-PnpDevice -Class Mouse -PresentOnly -Status OK | ForEach-Object { 
	"$($_.Name): $($_.DeviceID)"; 
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\$($_.DeviceID)\Device Parameters" -Name FlipFlopWheel -Value $mode;
	"+--- Value of FlipFlopWheel is set to " + (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\$($_.DeviceID)\Device Parameters").FlipFlopWheel + "`n" 
}
