#UpdateSyConfig.ps1 
# Update the system configuration files
param (
    [switch]$NoGit,
    [switch]$NoHW,
    [switch]$NoSW,
    [switch]$NoWinget,
    [switch]$NoChoco,
    [int]$JsonDepth = 8
)

function Ensure-YamlModule {
    if (-not (Get-Module -ListAvailable -Name 'powershell-yaml')) {
        Write-Host "powershell-yaml module not found. Installing..." -ForegroundColor Yellow
        Install-Module -Name powershell-yaml -Force -Scope CurrentUser
    } else {
        Write-Host "powershell-yaml module is already installed." -ForegroundColor Green
    }
    Import-Module powershell-yaml
}

function Update-SystemConfiguration {
    param (
        [string]$yamlFilePath = "sysconfig.yaml",
        [string]$GitRepositoryPath = "C:\Users\uv\OneDrive\PowerShell",
        [string]$configFolder = ".config",
        [int]$JsonDepth = 5
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
        param (
            [string]$OutputFile = $null
        )
    
        # Check if Chocolatey is installed
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            throw "Chocolatey is not installed on this system."
        }
    
        # Retrieve installed Chocolatey packages
        $chocoList = choco list -l
    
        $parsedPackages = $chocoList | ForEach-Object {
            $fields = $_ -split '\|' # Split by the '|' delimiter used by choco
            [PSCustomObject]@{
                Name    = $fields[0]
                Version = $fields[1]
            }
        }
    
        # Convert to JSON
        $jsonObject = $parsedPackages | ConvertTo-Json -Depth 1
    
        # If an output file is provided, save the JSON to the file
        if ($OutputFile) {
            try {
                $jsonObject | Set-Content -Path $OutputFile -Encoding UTF8
                Write-Host "Configuration saved to $OutputFile"
            } catch {
                Write-Error "Failed to save JSON to file: $_"
            }
        }
    
        # Return the parsed object
        return $parsedPackages
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
        $configs.registrySoftware | ConvertTo-Json -Depth $JsonDepth | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath "$configFolder\registrySoftware.json")
    }
    if (-Not $NoWinget) {
        $configs.wingetPackages = Get-WingetPackagesConfig
        $configs.wingetPackages | ConvertTo-Json -Depth $JsonDepth | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath "$configFolder\wingetPackages.json")
    }
    if (-Not $NoChoco) {
        $configs.chocoPackages = Get-ChocoPackagesConfig
        $configs.chocoPackages | ConvertTo-Json -Depth $JsonDepth | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath "$configFolder\chocoPackages.json")
    }
    if (-Not $NoHW) {
        $configs.hardwareConfig = Get-HardwareConfig
        $configs.hardwareConfig | ConvertTo-Json -Depth $JsonDepth | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath "$configFolder\hardwareConfig.json")
    }

    # Check if something has changed using git
    if (-Not $NoGit) {
        Set-Location -Path $GitRepositoryPath
        $gitStatus = git status --porcelain

        if ($gitStatus) {
            # Create or update the yaml file with the complete config
            $configs | ConvertTo-Yaml | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath $yamlFilePath)
            Write-Host "Configuration has changed. Updating YAML file and committing changes..." -ForegroundColor Cyan

            # Log the changes in red
            $gitStatus | ForEach-Object { Write-Host $_ -ForegroundColor Red }

            # Commit the changes
            git add .
            git commit -m "New config in $($gitStatus | ForEach-Object { $_ -replace '^\s*\S+\s+', '' } | Select-Object -First 1) found"
            Write-Host "Changes committed to the repository." -ForegroundColor Green
        } else {
            Write-Host "No changes detected in the configuration." -ForegroundColor Yellow
        }
    }
}

# Main logic
Ensure-YamlModule
Update-SystemConfiguration -JsonDepth $JsonDepth
