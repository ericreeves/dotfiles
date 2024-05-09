function Enable-Natural-Scroll
{
	param (
		[String] $path
	)

    Write-Host "Configuring natural scrolling feature for your mouse..." -ForegroundColor Cyan

    # the reg path has changed since win11
    $reg_path = "HKLM:\SYSTEM\CurrentControlSet\Enum\$path\Device Parameters"

    if ($args[0] -eq "reverse") {
        Set-ItemProperty -Path $reg_path -Name FlipFlopWheel -Value 0
        Write-Host "Natural scrolling feature for your mouse has been DISABLED" -ForegroundColor Green
        exit
    }
    Set-ItemProperty -Path $reg_path -Name FlipFlopWheel -Value 1
    Write-Host "Natural scrolling feature for your mouse has been ENABLED" -ForegroundColor Green

}

# sudo!
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}
# check if we have admin
# $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
# if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	# Write-Host -ForegroundColor Red "Need admin privilege to modify the registry"
	# exit 1
# }

Write-Host "Finding your USB mouse..." -ForegroundColor Cyan

$mouses = Get-PnpDevice -Class Mouse
if (!$mouses) {
    Write-Host -ForegroundColor Red "Could not find your USB mouse"
    exit 1
}

# set up every mouse
foreach ($mouse in $mouses) {
    $name = $mouse.FriendlyName
    $path = $mouse.InstanceID

    if (!($path -like "HID\VID*")) {
        Write-Host -ForegroundColor Yellow "Skipping"$path
        continue
    }

    Write-Host "Found $name ($path)" -ForegroundColor Green
	$Selection = read-host "Configure Natural Scrolling on '$name'? (y/N): "
	Switch ($Selection) 
		{ 
			Y { 
				Write-host "Configuring $path" 
				Enable-Natural-Scroll -path $path
			}
			default {Write-Host "Skipping...";Continue} 
		} 
	Write-Host ""

}