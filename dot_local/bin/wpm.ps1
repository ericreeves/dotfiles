param(
    [Parameter(Position=0)]
    [ValidateSet('start', 'stop', 'restart', 'status', 'enable-autostart', 'disable-autostart')]
    [string]$Command,

    [Parameter(Position=1)]
    [ValidateSet('scheduled_task', 'registry_run', 'startup_symlink')]
    [string]$Method
)

$ScriptPath = $PSCommandPath
$ConfigPath = "$HOME\.config\wpm\wpm.json"

function Load-Config {
    if (-not (Test-Path $ConfigPath)) {
        Write-Error "Config file not found at $ConfigPath"
        Write-Host "Please create the config file with the following structure:"
        Write-Host '{
  "environment_variables": {},
  "applications": [
    {
      "start_cmd": "app.exe",
      "start_argument_list": [],
      "stop_cmd": "app.exe",
      "stop_argument_list": ["stop"],
      "process_name": "app"
    }
  ]
}'
        exit 1
    }

    try {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

        # Validate required fields
        if (-not $config.applications) {
            Write-Error "Config must contain 'applications' array"
            exit 1
        }

        foreach ($app in $config.applications) {
            if (-not $app.start_cmd) {
                Write-Error "Each application must have 'start_cmd' defined"
                exit 1
            }
        }

        return $config
    }
    catch {
        Write-Error "Failed to parse config file: $_"
        exit 1
    }
}

$Config = Load-Config

function Start-Wpm {
    # Set environment variables from config
    if ($Config.environment_variables) {
        foreach ($var in $Config.environment_variables.PSObject.Properties) {
            $varName = $var.Name
            $varValue = $ExecutionContext.InvokeCommand.ExpandString($var.Value)
            [System.Environment]::SetEnvironmentVariable($varName, $varValue, 'User')
            Write-Verbose "Set environment variable: $varName = $varValue"
        }
    }

    # Start applications from config
    foreach ($app in $Config.applications) {
        $startCmd = $app.start_cmd
        $startArgs = if ($app.start_argument_list) { $app.start_argument_list } else { @() }
        $appName = Split-Path -Leaf $startCmd

        Write-Host "Starting $appName..."
        Start-Process $startCmd -ArgumentList $startArgs -WindowStyle Hidden
    }

    # Give processes a moment to start
    Start-Sleep -Seconds 1

    # Show status
    Write-Host ""
    Status-Wpm
}

function Stop-Wpm {
    # Try graceful shutdown for apps with stop_cmd
    foreach ($app in $Config.applications) {
        if ($app.stop_cmd) {
            $stopArgs = if ($app.stop_argument_list) { $app.stop_argument_list } else { @() }
            $appName = Split-Path -Leaf $app.stop_cmd
            Write-Host "Stopping $appName gracefully..."
            Start-Process $app.stop_cmd -ArgumentList $stopArgs -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
        }
    }

    # Give processes a moment to shut down gracefully
    Start-Sleep -Seconds 2

    # Force terminate processes that are still running
    foreach ($app in $Config.applications) {
        if ($app.process_name) {
            $processes = Get-Process -Name $app.process_name -ErrorAction SilentlyContinue

            # Filter by process_path if specified
            if ($app.process_path -and $processes) {
                $processes = $processes | Where-Object { $_.Path -eq $app.process_path }
            }

            if ($processes) {
                $appName = if ($app.start_cmd) { Split-Path -Leaf $app.start_cmd } else { $app.process_name }
                Write-Host "Force killing $appName..."
                $processes | Stop-Process -Force
            }
        }
    }

    # Show status
    Write-Host ""
    Status-Wpm
}

function Restart-Wpm {
    Stop-Wpm
    Start-Sleep -Seconds 1
    Start-Wpm
}

function Status-Wpm {
    Write-Host "Application Status:"
    Write-Host ""

    foreach ($app in $Config.applications) {
        $appName = if ($app.start_cmd) { Split-Path -Leaf $app.start_cmd } else { "Unknown" }

        if (-not $app.process_name) {
            Write-Host "  $appName : Cannot check status (process_name not defined in config)"
            continue
        }

        $processes = Get-Process -Name $app.process_name -ErrorAction SilentlyContinue

        # Filter by process_path if specified
        if ($app.process_path -and $processes) {
            $processes = $processes | Where-Object { $_.Path -eq $app.process_path }
        }

        if ($processes) {
            $count = ($processes | Measure-Object).Count
            Write-Host "  $appName ($($app.process_name)) : Running ($count process(es))" -ForegroundColor Green
        } else {
            Write-Host "  $appName ($($app.process_name)) : Not running" -ForegroundColor Red
        }
    }
}

function Enable-AutostartTask {
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`" start"
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    Register-ScheduledTask -TaskName "Wpm Start" -Action $action -Trigger $trigger -RunLevel Highest -Force
    Write-Host "Scheduled task 'Wpm Start' created successfully"
    Write-Host "Points to: $ScriptPath"
    Write-Host "WARNING: If you move or rename this script, you'll need to rerun this command"
}

function Disable-AutostartTask {
    Unregister-ScheduledTask -TaskName "Wpm Start" -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Scheduled task 'Wpm Start' removed"
}

function Enable-AutostartRegistry {
    $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    $regValue = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`" start"
    Set-ItemProperty -Path $regPath -Name 'WpmStart' -Value $regValue
    Write-Host "Registry autostart enabled at $regPath\WpmStart"
    Write-Host "Points to: $ScriptPath"
    Write-Host "WARNING: If you move or rename this script, you'll need to rerun this command"
}

function Disable-AutostartRegistry {
    $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    Remove-ItemProperty -Path $regPath -Name 'WpmStart' -ErrorAction SilentlyContinue
    Write-Host "Registry autostart removed from $regPath\WpmStart"
}

function Enable-AutostartShellStartup {
    $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcutPath = "$startupFolder\Wpm Start.lnk"

    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`" start"
    $shortcut.WindowStyle = 7  # Minimized
    $shortcut.Save()

    Write-Host "Startup folder shortcut created at $shortcutPath"
    Write-Host "Points to: $ScriptPath"
    Write-Host "WARNING: If you move or rename this script, you'll need to rerun this command"
}

function Disable-AutostartShellStartup {
    $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcutPath = "$startupFolder\Wpm Start.lnk"

    Remove-Item -Path $shortcutPath -ErrorAction SilentlyContinue
    Write-Host "Startup folder shortcut removed from $shortcutPath"
}

function Enable-Autostart {
    if (-not $Method) {
        Write-Error "Method parameter is required for enable-autostart"
        Write-Host "Usage: wpm.ps1 enable-autostart <method>"
        Write-Host "Valid methods: scheduled_task, registry_run, startup_symlink"
        exit 1
    }

    Write-Host "Enabling autostart using method: $Method"

    switch ($Method) {
        'scheduled_task' { Enable-AutostartTask }
        'registry_run' { Enable-AutostartRegistry }
        'startup_symlink' { Enable-AutostartShellStartup }
    }
}

function Disable-Autostart {
    Write-Host "Disabling all autostart methods..."
    Disable-AutostartTask
    Disable-AutostartRegistry
    Disable-AutostartShellStartup
    Write-Host "All autostart methods disabled"
}

# Execute command
switch ($Command) {
    'start' { Start-Wpm }
    'stop' { Stop-Wpm }
    'restart' { Restart-Wpm }
    'status' { Status-Wpm }
    'enable-autostart' { Enable-Autostart }
    'disable-autostart' { Disable-Autostart }
    default {
        Write-Host "Usage: wpm.ps1 <command> [method]"
        Write-Host ""
        Write-Host "Config file: $ConfigPath"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  start                             - Start desktop processes from config"
        Write-Host "  stop                              - Stop desktop processes from config"
        Write-Host "  restart                           - Restart desktop processes"
        Write-Host "  status                            - Check status of desktop processes"
        Write-Host "  enable-autostart <method>         - Enable autostart (scheduled_task, registry_run, startup_symlink)"
        Write-Host "  disable-autostart                 - Disable all autostart methods"
    }
}
