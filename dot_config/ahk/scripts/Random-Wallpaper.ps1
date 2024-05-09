#
# Uses https://github.com/federico-paolillo/set-wallpaper
#
# Author: Eric Reeves (eric@alluvium.com)
#

param ([string]$WallPaperPath)

function Get-Random-Image {
	param (
		[string]$WallPaperPath = "$home\OneDrive\Pictures\Wallpaper\2880x1800"
	)
	$Wallpaper = Get-ChildItem -Path $WallPaperPath -recurse | Where-Object {($_.extension -eq ".jpg" -or $_.extension -eq ".png" -or $_.extension -eq ".jpeg")} | Get-Random -Count 1 | ForEach-Object { $_.FullName } 
	Write-Output "$Wallpaper"
}

# Set Wallpaper Only on 2nd Monitor
# Get-Monitor | Select-Object -skip 1 | Select-Object -First 1 | Set-WallPaper -Path C:\Wallpapers\nature.jpg

$WallPaper = Get-Random-Image -WallPaperPath $WallPaperPath
$WallPaper | Out-File "$home\OneDrive\Pictures\Wallpaper\current-wallpaper.txt"
$WallPaper
Set-AllDesktopWallpapers -Path $WallPaper
