#UpdateSyConfig.ps1 
# Update the system configuration files
<# 
.SYNOPSIS
    Updates the system configuration files with optional exclusions.

.DESCRIPTION
    This script updates the system configuration files and allows selective exclusions 
    for various update operations, such as excluding Git updates, hardware configuration updates, etc.
    The level of JSON output can also be customized using the `JsonDepth` parameter.

.PARAMETER NoGit
    Excludes updates to Git configuration and repositories.

.PARAMETER NoHW
    Excludes updates to the hardware configuration file.

.PARAMETER NoCD
    Excludes updates to connected device configuration.

.PARAMETER NoSW
    Excludes updates to the software configuration file.

.PARAMETER NoWinget
    Excludes updates to the winget package manager configuration.

.PARAMETER NoChoco
    Excludes updates to the Chocolatey package manager configuration.

.PARAMETER JsonDepth
    Specifies the depth of JSON output for any serialized data. Defaults to 8.

.EXAMPLE
    # Update all configuration files with the default JSON depth.
    .\UpdateSyConfig.ps1

.EXAMPLE
    # Update system configuration while excluding Git and Chocolatey updates.
    .\UpdateSyConfig.ps1 -NoGit -NoChoco

.EXAMPLE
    # Update system configuration with a custom JSON depth of 10 and exclude software updates.
    .\UpdateSyConfig.ps1 -NoSW -JsonDepth 10

.NOTES
    - Ensure you have the necessary permissions to modify system configuration files.
    - Customize the script as needed for additional exclusions or functionality.
#>

param (
    [switch]$Git = $false,
    [switch]$NoHW,
    [switch]$NoCD,
    [switch]$NoSW,
    [switch]$NoWinget,
    [switch]$NoChoco,
    [int]$JsonDepth = 10
    
)
###############################################################################################################    
# preconditions
###############################################################################################################    
function CheckPreconditions {
    param (
        [String]$MyConfigFolder
    )

    function CheckFolder {
        param(
            [string]$folderPath = "C:\Path\To\Folder"
        )

        # Check and create folder if necessary
        if (-not (Test-Path -Path $folderPath -PathType Container)) {
            New-Item -ItemType Directory -Path $folderPath | Out-Null
            Write-Output "The folder has been created: $folderPath"
        }
        else {
            Write-Output "The folder already exists: $folderPath"
        }
    }
    function Install-YamlModule {
        if (-not (Get-Module -ListAvailable -Name 'powershell-yaml')) {
            Write-Host "powershell-yaml module not found. Installing..." -ForegroundColor Yellow
            Install-Module -Name powershell-yaml -Force -Scope CurrentUser
        }
        else {
            Write-Host "powershell-yaml module is already installed." -ForegroundColor Green
        }
        Import-Module powershell-yaml
    }
    # function Install-PackageProviderChocolatey {
    #     if (-not (Get-Package | Where-Object { $_.ProviderName -eq 'Chocolatey' })) {
    #         Write-Host "Chocolatey provider package not found. Installing..." -ForegroundColor Yellow
    #         Get-PackageProvider -Name Chocolatey
    #     }
    #     else {
    #         Write-Host "Chocolatey package is already installed." -ForegroundColor Green
    #     }
    #     Install-PackageProvider -Name Chocolatey -Force -Scope CurrentUser
    # }

    function CheckPSVerion {    
        # Ensure the script is running in PS7
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7 or higher."
            return
        }
    }
    CheckPSVerion
    CheckFolder -folderPath $MyConfigFolder
    Install-YamlModule
#    Install-PackageProviderChocolatey
}

###############################################################################################################    
# config collection
###############################################################################################################    

function Update-SystemConfiguration {
    param (
        [int]$JsonDepth,
        [string]$YamlConfig,
        [string]$GitRepositoryPath 
    )
    $MyConfigFolder = (Join-Path -Path $GitRepositoryPath -ChildPath ".myconfig")
    CheckPreconditions -MyConfigFolder  $MyConfigFolder
    # Collect installed software
    # Function to retrieve registry software configuration
    function Get-RegistrySoftwareConfig {
        Write-Host "Collecting registry software configuration..." -ForegroundColor Cyan
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

    # Function to retrieve choco packages configuration
    function Get-ChocoPackagesConfig {
        param (
            [string]$OutputFile = $null
        )
        Write-Host "Collecting Chocolatey packages configuration..." -ForegroundColor Cyan
    
        # Check if Chocolatey is installed
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            throw "Chocolatey is not installed on this system."
        }
    
        # Retrieve installed Chocolatey packages
        $chocoList = choco list
    
        $parsedChocoPackages = $chocoList | ForEach-Object {
            $fields = $_ -split '\|' # Split by the '|' delimiter used by choco
            [PSCustomObject]@{
                Name    = $fields[0]
                Version = $fields[1]
            }
        }
        return $parsedChocoPackages
    }

    # Function to retrieve winget packages configuration
    function Get-WingetPackagesConfig {
        Write-Host "Collecting winget packages configuration..." -ForegroundColor Cyan
        # Placeholder for actual implementation
        $wingetList = winget list
        $parsedWingetPackages = $wingetList | Select-Object -Skip 2 | ForEach-Object {
            $fields = $_ -split '\s{2,}'
            [PSCustomObject]@{
                Name    = $fields[0]
                Id      = $fields[1]
                Version = $fields[2]
            }
        }
        return $parsedWingetPackages
    }

    # Function to retrieve hardware configuration
    function Get-HardwareConfig {
        Write-Host "Collecting hardware configuration..." -ForegroundColor Cyan

        $system = Get-CimInstance -ClassName Win32_ComputerSystem
        $bios = Get-CimInstance -ClassName Win32_BIOS
        $cpu = Get-CimInstance -ClassName Win32_Processor
        $baseBoard = Get-CimInstance -ClassName Win32_BaseBoard
        $gpu = Get-CimInstance -ClassName Win32_VideoController
        $memory = Get-CimInstance -ClassName Win32_PhysicalMemory
        $disks = Get-CimInstance -ClassName Win32_DiskDrive

        return [PSCustomObject]@{
            ComputerSystem  = $system
            BIOS            = $bios
            CPU             = $cpu
            BaseBoard       = $baseBoard
            VideoController = $gpu
            PhysicalMemory  = $memory
            DiskDrives      = $disks
        }
    }

    # Function to retrieve connected hardware devices
    function Get-ConnectedDevices {
        Write-Host "Collecting connected devices configuration..." -ForegroundColor Cyan
        $usbDevices = Get-CimInstance -ClassName Win32_USBControllerDevice | 
        ForEach-Object {
            [PSCustomObject]@{
                DeviceName = ($_.Dependent -replace '^.*?DeviceID="', '').Split(',')[0]
                Controller = $_.Antecedent -replace '^.*?DeviceID="', ''
            }
        }

        $monitors = Get-CimInstance -ClassName Win32_DesktopMonitor | 
        Select-Object Name, DeviceID, ScreenHeight, ScreenWidth

        $networkAdapters = Get-CimInstance -ClassName Win32_NetworkAdapter | 
        Where-Object { $_.NetConnectionStatus -eq 2 } | # Only active adapters
        Select-Object Name, MACAddress, NetConnectionID

        $audioDevices = Get-CimInstance -ClassName Win32_SoundDevice | 
        Select-Object Name, Status

        $storageDevices = Get-CimInstance -ClassName Win32_DiskDrive | 
        Select-Object Model, Size, MediaType, InterfaceType

        return [PSCustomObject]@{
            USBDevices       = $usbDevices
            Monitors         = $monitors
            NetworkAdapters  = $networkAdapters
            AudioDevices     = $audioDevices
            StorageDevices   = $storageDevices
            connectedDevices = $connectedDevices        
        }
    }

     #####################################################################################################################

    $systemConfiguration = [PSCustomObject]@{
        Timestamp              = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        RegistrySoftware       = Get-RegistrySoftwareConfig
        WingetPackages         = Get-WingetPackagesConfig
        HardwareInformation    = Get-HardwareConfig
        ChocoPackages          = Get-ChocoPackagesConfig
        PythonPackages         = $pythonPackages
        ConnectedDevicesConfig = Get-ConnectedDevices
    }

    function ConvertTo-CanonicalJson {
        param (
            [Parameter(Mandatory = $true)]
            [PSObject]$InputObject,
            $JsonDepth = 10
        )
    
        # Convert to JSON with sorted keys and no whitespace
        $json = $InputObject | 
            ConvertTo-Json -Depth 10 -Compress | 
            ConvertFrom-Json | 
            Sort-Object | 
            ConvertTo-Json -Depth 10 -Compress
    
        return $json
    }
    # Convert to JSON (full object)
    Write-host $systemConfiguration -ForegroundColor Gray
    foreach ($property in $systemConfiguration.PSObject.Properties) {
        Write-Host "Property: $($property.Name)" -ForegroundColor Magenta
        if ($null -eq $property.Value ) {
            Write-Warning "No data found for '$($property.Name)'." 
            continue
        } else {
            Write-Host "Property: $($property.Value).Substring(0, $MaxLength - 3)" -ForegroundColor Cyan
        }
        $jsonChunk = Canonical-Json -InputObject $property.Value -JsonDepth $JsonDepth
        if ($jsonChunk -like "*...*") {
            Write-Warning "Data for '$($property.Name)' might be truncated at depth $JsonDepth. Use a higher depth if needed."
        }
        $filePath = Join-Path -Path $MyConfigFolder -ChildPath ("{0}.json" -f $property.Name)
        Write-Host "Writing to file: $filePath" -ForegroundColor Green 
        $MaxLength = 80
        $truncated = $jsonChunk.Substring(0, $MaxLength - 3) + '...'    
        Write-Host $truncated -ForegroundColor Gray
        Set-Content -Path $filePath -Value $jsonChunk -Encoding UTF8
    }
}

function CommitChanges {
    
    # Check if something has changed using git
    Set-Location -Path $GitRepositoryPath
    $gitStatus = git status --porcelain

    if ($gitStatus) {
        # foreach ($item in $systemConfiguration.GetEnumerator()) {
        #     # Create or update the yaml file with the complete config
        # $configs | ConvertTo-Yaml | Set-Content -Path (Join-Path -Path $GitRepositoryPath -ChildPath $yamlFilePath)
        Write-Host "Configuration has changed. Updating YAML file and committing changes..." -ForegroundColor Cyan

        # Log the changes in red
        $gitStatus | ForEach-Object { Write-Host $_ -ForegroundColor Red }

        # Commit the changes
        #     git add .
        #     git commit -m "New config in $($gitStatus | ForEach-Object { $_ -replace '^\s*\S+\s+', '' } | Select-Object -First 1) found"
        #     Write-Host "Changes committed to the repository." -ForegroundColor Green
        # }
        else {
            Write-Host "No changes detected in the configuration." -ForegroundColor Yellow
        }
    }
}

# Main logic
# pass on parms from commandline
Update-SystemConfiguration -JsonDepth $JsonDepth -YamlConfig "system_configuration.yaml" -GitRepositoryPath  "C:\Users\uv\OneDrive\PowerShell"
if ( $Git ) { CommitChanges }
