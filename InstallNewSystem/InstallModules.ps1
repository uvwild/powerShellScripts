Install-Module -Name PSDesiredStateConfiguration -Force

function InstallModules {
    foreach ($module in $modules) {
        # Check if the module is already installed
        if (!(Get-Module -ListAvailable -Name $module)) {
            try {
                $installCommand = "Install-Module -Name $module $DefaultInstallModuleOptions"
                Write-Output "Installing $module..."
                Invoke-Expression $installCommand
                Write-Output "$module installed successfully."
            } catch {
                Write-Output "Failed to install ${module}: $_"
            }
        } else {
            Write-Output "$module is already installed."
        }
    }
}