$powerManagement = Get-CimInstance -ClassName 'MSPower_DeviceEnable' -Namespace 'root/WMI'
$usbDevices      = Get-CimInstance -ClassName 'Win32_PnPEntity' -Filter 'PNPClass = "USB"'


$devicesToAdjust = [Collections.Generic.List[object]]::new()

$usbDevices | ForEach-Object { 
	$devicesToAdjust.Add(($powerManagement | Where-Object 'InstanceName' -Like "*$($_.PNPDeviceID)*"))
}



$usbDevices | ForEach-Object { 
	$powerManagement | Where-Object 'InstanceName' -Like "*$($_.PNPDeviceID)*" 
} | Set-CimInstance -Property @{ Enable = $false }

$devicesToAdjust # Inspect the devices, then pipe to Set-CimInstance afterwards
