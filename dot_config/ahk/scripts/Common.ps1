# ----------------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------------

$WindowsBox_Folder = "$env:userprofile\.config\WindowsBox"
$AHK_Folder = "$env:userprofile\.config\WindowsBox\ahk"
$AHK_Filename = "komorebi.ahk"
$AHK_Shortcuts_Filename = "AppShortcuts.ahk"
$Komorebi_Bin_Folder = "$env:userprofile\scoop\shims"
$Python_Bin_Folder = "$env:userprofile\.config\WindowsBox\python3"
$Yasb_Folder = "$env:userprofile\.config\WindowsBox\yasb"
$Yasb_Config_Folder = "$env:userprofile\.yasb"

Function Execute-Command ($FilePath, $ArgumentList, $WorkingDirectory, $Title)
{
  Try {
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $FilePath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.WorkingDirectory = $WorkingDirectory
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $ArgumentList
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    if ($p.Start())
    {
        $StreamReader = $p.StandardOutput
        while (-not $StreamReader.EndOfStream)
        {
            $line = $StreamReader.ReadLine()
            write-host $line
        }
        $ps.WaitForExit()
    
        if ($ps.ExitCode -eq 0)
        {
            write-host "Command Successful"
        }
        else
        {
            write-host "Error Executing Command"
        }
    }
    else
    {
        write-host "Unable to Start"
    }
    # [pscustomobject]@{
    #     command = $Title
    #     stdout = $p.StandardOutput.ReadToEnd()
    #     stderr = $p.StandardError.ReadToEnd()
    #     ExitCode = $p.ExitCode
    # }
    $p.WaitForExit()
    # $p.StandardOutput.ReadToEnd();
    Write-Output ""
  }
  Catch {
     exit
  }
}

function Write-Output-Format
{
    param (
        [String] $Message
    )
    # Write-Output "--------------------------------------------------"
    # Write-Output "$Message"
    # Write-Output "--------------------------------------------------"
    Write-Output "--- $Message"
}

function Get-Process-Command
{
	param (
		[String] $Name
	)
	Get-WmiObject Win32_Process -Filter "name = '$Name.exe'" -ErrorAction SilentlyContinue | Select-Object CommandLine,ProcessId
}
function Wait-For-Process
{
    param
    (
		[String] $Name,
        [Switch] $IgnoreExistingProcesses
    )

    if ($IgnoreExistingProcesses)
    {
        $NumberOfProcesses = (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    }
    else
    {
        $NumberOfProcesses = 0
    }

    Write-Host "--- Waiting for $Name" -NoNewline
    while ( (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count -eq $NumberOfProcesses )
    {
        Write-Host '.' -NoNewline
        Start-Sleep -Milliseconds 400
    }

    Write-Host ''
}