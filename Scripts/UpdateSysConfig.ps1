#UpdateSyConfig.ps1 
# Update the system configuration files
param (
    [switch]$NoGit,
    [switch]$NoHW,
    [switch]$NoSW,
    [switch]$NoWinget,
    [switch]$NoChoco
)

function Update-SystemConfiguration {
    param (
        [string]$yamlFilePath = "sysconfig.json",
        [string]$GitRepositoryPath = "C:\Users\uv\OneDrive\PowerShell",
        [string]$configFolder = ".config"
    )

    # Check if the config folder exists, create if needed
    if (-Not (Test-Path -Path (Join-Path -Path $GitRepositoryPath -ChildPath $configFolder))) {
        New-Item -ItemType Directory -Path (Join-Path -Path $GitRepositoryPath -ChildPath $configFolder) | Out-Null
    }

    # Function to retrieve registry software configuration
    function Get-RegistrySoftwareConfig {
        # Placeholder for actual implementation
        $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        $softwareConfigs = Get-ChildItem -Path $registryPath | ForEach-Object {
            $app = Get-ItemProperty -Path $_.PSPath
            [PSCustomObject]@{
                DisplayName    = $app.DisplayName
                DisplayVersion = $app.DisplayVersion
                Publisher      = $app.Publisher
                InstallDate    = $app.InstallDate
            }
        } | Where-Object { $null -ne $_.DisplayName }

        return $softwareConfigs
    }

    # Function to retrieve winget packages configuration
    function Get-WingetPackagesConfig {
        # Placeholder for actual implementation
        $wingetList = winget list
        $parsedPackages = $wingetList | Select-Object -Skip 2 | ForEach-Object {
            $fields = $_ -split '\s{2,}'
            [PSCustomObject]@{
                Name    = $fields[0]
                Id      = $fields[1]
                Version = $fields[2]
            }
        }
        return $parsedPackages
    }

    # Function to retrieve choco packages configuration
    function Get-ChocoPackagesConfig {
        # Placeholder for actual implementation
        $chocoOutput = choco list --localonly
        $parsedChocoPackages = $chocoOutput | Select-Object -Skip 1 | ForEach-Object {
            $fields = $_ -split '\s+', 2
            [PSCustomObject]@{
                Name    = $fields[0]
                Version = $fields[1]
            }
        }
        return $parsedChocoPackages 
    }

    # Function to retrieve hardware configuration
    function Get-HardwareConfig {
        $system    = Get-CimInstance -ClassName Win32_ComputerSystem
        $bios      = Get-CimInstance -ClassName Win32_BIOS
        $cpu       = Get-CimInstance -ClassName Win32_Processor
        $baseBoard = Get-CimInstance -ClassName Win32_BaseBoard
        $gpu       = Get-CimInstance -ClassName Win32_VideoController
        $memory    = Get-CimInstance -ClassName Win32_PhysicalMemory
        $disks     = Get-CimInstance -ClassName Win32_DiskDrive

        [PSCustomObject]@{
            ComputerSystem = $system
            BIOS           = $bios
            CPU            = $cpu
            BaseBoard      = $baseBoard
            VideoController= $gpu
            PhysicalMemory = $memory
            DiskDrives     = $disks
        }
    }

    # Collect configurations
    $configs = @{}
    if (-Not $NoSW) {
        $configs.registrySoftware = Get-RegistrySoftwareConfig
        $configs.registrySoftware | ConvertTo-Json | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath "$configFolder\registrySoftware.json")
    }
    if (-Not $NoWinget) {
        $configs.wingetPackages = Get-WingetPackagesConfig
        $configs.wingetPackages | ConvertTo-Json | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath "$configFolder\wingetPackages.json")
    }
    if (-Not $NoChoco) {
        $configs.chocoPackages = Get-ChocoPackagesConfig
        $configs.chocoPackages | ConvertTo-Json | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath "$configFolder\chocoPackages.json")
    }
    if (-Not $NoHW) {
        $configs.hardwareConfig = Get-HardwareConfig
        $configs.hardwareConfig | ConvertTo-Json | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath "$configFolder\hardwareConfig.json")
    }

    # Check if something has changed using git
    if (-Not $NoGit) {
        Set-Location -Path $GitRepositoryPath
        $gitStatus = git status --porcelain

        if ($gitStatus) {
            # Create or update the yaml file with the complete config
            $configs | ConvertTo-Yaml | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath $yamlFilePath)

            # Commit the changes
            git add .
            git commit -m "New config in $($gitStatus | ForEach-Object { $_ -replace '^\s*\S+\s+', '' } | Select-Object -First 1) found"
        }
    }
}

# Main logic
Update-SystemConfiguration
