# FZF Helper Functions - Internal implementation details not shown in help documentation

function Invoke-FzfAction {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('file', 'directory')]
        [string]$Type,
        [string]$Path = '.',
        [string]$Action = 'cd',
        [string]$SearchString = ''
    )
    
    # Store original location in case we need to revert
    $originalLocation = Get-Location
    
    # Change to the specified path, or stay in current directory if not specified
    if ($Path -ne '.') {
        if (-not (Test-Path $Path)) {
            Write-Output "Path does not exist: $Path"
            return
        }
        if ($Type -eq 'directory') {
            Set-Location $Path
        }
    }
    
    # Set up FZF environment based on type
    if ($Type -eq 'file') {
        $Env:FZF_DEFAULT_COMMAND = 'fd --type f --strip-cwd-prefix --hidden --exclude .git'
        $Env:FZF_DEFAULT_OPTS = $Env:FZF_FILE_OPTS
    } elseif ($Type -eq 'directory') {
        $Env:FZF_DEFAULT_COMMAND = 'fd --type d --strip-cwd-prefix --hidden --exclude .git'
        $Env:FZF_DEFAULT_OPTS = $Env:FZF_DIRECTORY_OPTS
    } else {
        Write-Error "Invalid type '$Type'. Must be 'file' or 'directory'."
        return
    }
    
    $Host.UI.RawUI.WindowTitle = 'FZF'
    
    if ([string]::IsNullOrWhiteSpace($SearchString)) {
        $selected = fzf
    } else {
        $selected = fzf --query "$SearchString"
    }
    
    if (![string]::IsNullOrWhiteSpace($selected)) {
        # Determine target path based on type
        if ($Type -eq 'file') {
            $targetPath = Split-Path -Parent -Path $selected
            $targetItem = $selected
        } elseif ($Type -eq 'directory') {
            $targetPath = $selected
            $targetItem = '.'
        } else {
            Write-Error "Invalid type '$Type'. Must be 'file' or 'directory'."
            return
        }
        
        switch ($Action.ToLower()) {
            'explorer' { explorer $targetPath }
            'nvim' { 
                $p = Split-Path -Leaf -Path (Get-Location)
                $Host.UI.RawUI.WindowTitle = "$p"
                Set-Location $targetPath
                nvim $targetItem
                Set-Location $originalLocation
            }
            'editor' {
                if ($Env:EDITOR) {
                    Set-Location $targetPath
                    & $Env:EDITOR $targetItem
                    Set-Location $originalLocation
                } else {
                    Write-Output 'EDITOR environment variable not set'
                }
            }
            'invoke' {
                if ($Type -eq 'file') {
                    Invoke-Item $selected
                } else {
                    Invoke-Item $targetPath
                }
            }
        }
    }
}

function Invoke-FzfFileAction {
    param(
        [string]$Path = '.',
        [string]$Action = 'cd',
        [string]$SearchString = ''
    )
    Invoke-FzfAction -Type 'file' -Path $Path -Action $Action -SearchString $SearchString
}

function Invoke-FzfDirectoryAction {
    param(
        [string]$Path = '.',
        [string]$Action = 'cd',
        [string]$SearchString = ''
    )
    Invoke-FzfAction -Type 'directory' -Path $Path -Action $Action -SearchString $SearchString
}