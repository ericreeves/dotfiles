Write-Output "--------------------------------------------------"
Write-Output " Building New Config"
Write-Output "--------------------------------------------------"
Invoke-Expression -Command "C:\Users\eric\.cargo\bin\komorebic.exe ahk-app-specific-configuration C:\Users\eric\Rice\komorebi-application-specific-configuration\applications.yaml"

Write-Output "--------------------------------------------------"
Write-Output " Copying New Config"
Write-Output "--------------------------------------------------"
Invoke-Expression -Command "cp C:\Users\eric\komorebi.generated.ahk C:\Users\eric\Rice\windowsbox\ahk\include\komorebi.generated.ahk"