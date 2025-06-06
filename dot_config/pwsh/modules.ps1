$modules = @(
    'Terminal-Icons'
    'PSReadLine'
    'PSFzf'
    'gsudoModule'
    'posh-git'
)

foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Scope CurrentUser -Force -SkipPublisherCheck
    }
    Import-Module -Name $module
}

