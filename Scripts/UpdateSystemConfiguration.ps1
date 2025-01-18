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
    [switch]$NoGit,
    [switch]$NoHW,
    [switch]$NoCD,
    [switch]$NoSW,
    [switch]$NoWinget,
    [switch]$NoChoco,
    [int]$JsonDepth = 8,
    [String] $myConfigFolder = (Join-Path -Path $GitRepositoryPath -ChildPath ".myconfig")
    
)
###############################################################################################################    
# preconditions
###############################################################################################################    
if (Get-Module -ListAvailable | Where-Object { $_.Name -eq "powershell-yaml" }) {
    Import-Module powershell-yaml -ErrorAction SilentlyContinue
    $yamlOutput = $allConfig | ConvertTo-Yaml
    if ($yamlOutput -like "*...*") {
        Write-Warning "Combined YAML might be truncated. Consider deeper serialization."
    }
    $yamlFilePath = Join-Path -Path $myConfigFolder -ChildPath "config.combined.yaml"
    Set-Content -Path $yamlFilePath -Value $yamlOutput -Encoding UTF8
}
else {
    Write-Warning "powershell-yaml is not installed, skipping YAML creation."
}

    
if (-not (Test-Path $myConfigFolder)) {
    New-Item -ItemType Directory -Path $myConfigFolder | Out-Null
}
############################################################################################################### 
# functions
###############################################################################################################    
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

function Install-YamlModule {
    if (-not (Get-Package | Where-Object { $_.ProviderName -eq 'Chocolatey' })) {
        Write-Host "Chocolatey provider package not found. Installing..." -ForegroundColor Yellow
        Get-PackageProvider -Name Chocolatey
    }
    else {
        Write-Host "Chocolatey package is already installed." -ForegroundColor Green
    }
    Install-PackageProvider -Name Chocolatey -Force -Scope CurrentUser
}

function Update-SystemConfiguration {
    param (
        [string]$yamlConfig = "system_configuration.yaml",
        [string]$GitRepositoryPath = "C:\Users\uv\OneDrive\PowerShell"
    )

    # Ensure the script is running in PS7
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Error "This script requires PowerShell 7 or higher."
        return
    }

    # Check if the config folder exists, create if needed
    if (-Not (Test-Path -Path (Join-Path -Path $GitRepositoryPath -ChildPath $configFolder))) {
        New-Item -ItemType Directory -Path (Join-Path -Path $GitRepositoryPath -ChildPath $configFolder) | Out-Null
    }
    
    # Collect installed software
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

    # Convert to JSON
    $jsonObject = $parsedPackages | ConvertTo-Json -Depth 1
    
    # If an output file is provided, save the JSON to the file
    if ($OutputFile) {
        try {
            $jsonObject | Set-Content -Path $OutputFile -Encoding UTF8
            Write-Host "Configuration saved to $OutputFile"
        }
        catch {
            Write-Error "Failed to save JSON to file: $_"
        }
    }
    
    # Return the parsed object
    return $parsedPackages
}

# Function to retrieve hardware configuration
function Get-HardwareConfig {
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

    # duplication here
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
# Convert to JSON (full object)
$systemConfiguration = [PSCustomObject]@{
    Timestamp           = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    InstalledSoftware   = $installedSoftware
    HardwareInformation = $hardwareInfo
    PSModules           = $psModules
    PythonPackages      = $pythonPackages
    WingetList          = $wingetOutput
}
    

# Place each configuration part in a separate file at depth 5
$configItems = @{
    installedsoftware = $installedSoftware
    connectedDevices  = $connectedDevices
    hardwareinfo      = $hardwareInfo
    psmodules         = $psModules
    pythonpackages    = $pythonPackages
    winget            = $wingetOutput
}
$maxDepth = 5
foreach ($item in $configItems.GetEnumerator()) {
    $jsonChunk = $item.Value | ConvertTo-Json -Depth $maxDepth -Compress
    if ($jsonChunk -like "*...*") {
        Write-Warning "Data for '$($item.Key)' might be truncated at depth $maxDepth. Use a higher depth if needed."
    }
    $filePath = Join-Path -Path $myConfigFolder -ChildPath ("config.{0}.json" -f $item.Key)
    Set-Content -Path $filePath -Value $jsonChunk -Encoding UTF8
}

# Combine all members into one YAML file (requires a module like powershell-yaml)
$allConfig = [ordered]@{}
foreach ($cItem in $configItems.GetEnumerator()) {
    $allConfig[$cItem.Key] = $cItem.Value
}

# If in Git repo, commit changes
if (Test-Path (Join-Path -Path $GitRepositoryPath -ChildPath ".git")) {
    Push-Location $GitRepositoryPath
    git add $OutputFile
    git commit -m "Updated system configuration: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    # Check Git status and commit changes if any
    git status
    $statusOutput = git status --porcelain
    if ($statusOutput) {
        $changedMembers = $statusOutput | ForEach-Object {
            if ($_ -match '^.[ARM] \s+\.myconfig\\config\.(\w+)\.json') {
                $matches[1]
            }
            elseif ($_ -match '^.[ARM] \s+\.myconfig\\config\.combined\.yaml') {
                "combined"
            }
        } | Sort-Object -Unique

        if ($changedMembers) {
            git add ".myconfig"
            git commit -m "new system configuration with changes in $($changedMembers -join ', ')"
        }
    }
    Pop-Location
}
else {
    Write-Warning "The specified path is not a Git repository. Skipping commit step."
}

Write-Output "System configuration updated and saved to $OutputFile and .myconfig."

