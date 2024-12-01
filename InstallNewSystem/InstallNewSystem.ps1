#InstallNewSystem
# Define the list of packages to install
$packages = @(
	# windows
    "Microsoft.PowerShell",
    "Microsoft.PowerToys",
    "Microsoft.Sysinternals",
    "CodeSector.TeraCopy",
    "HermannSchinagl.LinkShellExtension",
    "Microsoft.WindowsSDK.10.0.26100", 
	
	# dev
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "GitHub.GitHubDesktop",
	"OpenJS.NodeJS",
    "SoftDeluxe.FreeDownloadManager",
	
	# google
    "Google.PlatformTools",
    "Google.AndroidStudio",
    "Google.QuickShare",

	# system util
    "REALiX.HWiNFO",
    "CPUID.HWMonitor",
    "Sony.XperiaCompanion",
    "Canonical.Ubuntu.2404",
    "Genymobile.scrcpy",
    "Frontesque.scrcpy+",
#    "GlavSoft.TightVNC 2.8.85",
	
	# audio
    "Audacity.Audacity",
    "MusicBee.MusicBee",
    "SonicVisualiser.SonicVisualiser",
    "AsaphaHalifa.AudioRelay",
		
	# the chats
    "WhatsApp",
    "Telegram.TelegramDesktop",
    "OpenWhisperSystems.Signal",

	# cloud storage
    "Microsoft.OneDrive",
    "Google.GoogleDrive",
	
	# video
    "OBSProject.OBSStudio",
    "Gyan.FFmpeg", 
    "Videolan.vlc",
    "GianlucaPernigotto.Videomass",

	# browser mail
    "Google.Chrome",
    "Mozilla.Firefox",
    "Mozilla.Thunderbird",
    "Mailbird.Mailbird",
	
	# util
    "Governikus.AusweisApp",
    "7zip.7zip",
    "JAMSoftware.TreeSize.Free",
    "Notepad\+\+.Notepad\+\+",
    "IrfanSkiljan.IrfanView",
    "IrfanSkiljan.IrfanView.PlugIns",
    "CodeSector.TeraCopy",
    "ScooterSoftware.BeyondCompare.5",
    "TheDocumentFoundation.LibreOffice"
    "CrystalDewWorld.CrystalDiskInfo"
)

$remove = @(
    "Xbox tcui",
    "Xbox Identity Provider",
    "Xbox Game Speech Window",
    "Native Instruments Traktor Audio 10",
    "Native Instruments Traktor Audio 2",
    "Native Instruments Traktor Audio 6",
    "Native Instruments Traktor Kontrol D2",
    "Native Instruments Traktor Kontrol F1",
    "Native Instruments Traktor Kontrol S2",
    "Native Instruments Traktor Kontrol S4",
    "Native Instruments Traktor Kontrol S8",
    "",
    "",
    "",
    "Microsoft Tips",    
    "Solitaire & Casual Games",
    "Microsoft Journalx",
    "Microsoft.DevHome",
    "Bostrot.WSLManager",
	"" # to keep the last comma
)
# to disable install steps
function Test-CommandLineOption {
    param (
        [string]$Option
    )
    #Enum-Dict $PSBoundParameters
    # Check if the option is present in the command line arguments
    if ($PSBoundParameters.ContainsKey($Option) -and $args.Contains("-$Option")) {
        #Write-Host "Option=$Option $($PSBoundParameters[$Option])   $PSBoundParameters"
        
        return $true
    }
    return $false
}
function Update-SessionEnvironment {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Function to get the installation path of a winget package
function Get-WingetPackagePath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageId
    )
    
    try {
        # Get package information using winget show
        $packageInfo = winget show $PackageId
        
        # Look for the installation path in the package info
        $installPath = ($packageInfo | Where-Object { $_ -match "Installation Path:" }) -replace "Installation Path:\s*", ""
        
        if ($installPath) {
            return $installPath.Trim()
        }
        
        # Fallback to common installation paths if winget doesn't provide it
        $commonPaths = @{
            "Git.Git"                    = "${env:ProgramFiles}\Git\cmd"
            "Microsoft.PowerShell"       = "${env:ProgramFiles}\PowerShell\7"
            "Microsoft.VisualStudioCode" = "${env:LocalAppData}\Programs\Microsoft VS Code\bin"
            "FFmpeg"                     = "${env:ProgramFiles}\ffmpeg\bin"
            "Gyan.FFmpeg"                = "${env:ProgramFiles}\ffmpeg\bin"
        }
        
        if ($commonPaths.ContainsKey($PackageId)) {
            return $commonPaths[$PackageId]
        }
    }
    catch {
        Write-Host "Failed to get installation path for $PackageId" -ForegroundColor Yellow
        return $null
    }
    
    return $null
}

function Add-PathIfNotExist {
    param (
        [Parameter(Mandatory = $true)]
        [string]$NewPath,

        [Parameter()]
        [string]$scope = "Machine"
    )
    # Get the current PATH
    $currentPath = [System.Environment]::GetEnvironmentVariable('PATH', $scope)
    # Split the PATH into an array
    $pathArray = $currentPath -split ';'
    # Check if the new path already exists in the PATH
    if ($pathArray -notcontains $NewPath) {
        # Add the new path
        $newPathValue = $currentPath + ';' + $NewPath
        try {
            # Set the new PATH value
            [System.Environment]::SetEnvironmentVariable('PATH', $newPathValue, $scope)
            Write-Host "Added '$NewPath' to the system PATH." -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to add '$NewPath' to the system PATH. Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "'$NewPath' already exists in the system PATH." -ForegroundColor Yellow
    }
}



# Function to check if winget is installed
function Test-WingetInstalled {
    $wingetPath = (Get-Command winget -ErrorAction SilentlyContinue).Source
    winget --version
    return [bool]$wingetPath
}

function Get-WingetInstalledPackages {
    # Get the complete list of installed packages
    $installedPackages = winget list

    # Convert the output to an array of strings and remove empty lines
    $packageList = $installedPackages | Out-String -Stream | Where-Object { $_.Trim() -ne "" }

    # Remove the header lines (usually the first 2 lines)
    $packageList = $packageList | Select-Object -Skip 2

    return $packageList
}

# Get the list of installed packages
$installedPackages = Get-WingetInstalledPackages

function Test-WingetPackageInstalled($PackageId,$InstalledPackages) {
    if ($InstalledPackages | Where-Object { $_ -match $PackageId } ) {
        return $true
    }
    else {
        return $false
    }
}

# Function to check if a path contains executable files
function Test-ExecutablePath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    if (-not (Test-Path $Path)) {
        return $false
    }
    
    # Check for common executable extensions
    $executableFiles = Get-ChildItem -Path $Path -File | Where-Object {
        $_.Extension -in @('.exe', '.cmd', '.bat', '.ps1')
    }
    
    return $executableFiles.Count -gt 0
}

$silentInstall = $true
# Function to install a package using winget
function Install-Package($packageName) {
    $installCommand = "winget install $packageName"
    
    $installCommand += " --silent"
    $installCommand += " --nowarn"
    $installCommand += " --accept-source-agreements"
  
    Write-Host "Installing $packageName..." -ForegroundColor Green
    Write-Host "$installCommand"   -ForegroundColor Blue
    Invoke-Expression $installCommand

    # Get the installation path
    $packagePath = Get-WingetPackagePath -PackageId $packageName
        
    if ($packagePath -and (Test-ExecutablePath -Path $packagePath)) {
        Write-Host "Adding $packagePath to PATH..." -ForegroundColor Green
        Add-PathIfNotExist -NewPath $packagePath -scope "Machine"
        
        # Check for additional bin directories
        $binPath = Join-Path $packagePath "bin"
        if (Test-Path $binPath) {
            Add-PathIfNotExist -NewPath $binPath -scope "Machine"
        }
    }    
}
function Remove-Package($packageName) {
    if (-not ($packageName)) { return }
    $uninstallCommand = "winget uninstall `"$packageName`""

    $uninstallCommand += " --nowarn"
    Write-Host "Removing $packageName..." -ForegroundColor Red
    Write-Host "$uninstallCommand"   -ForegroundColor yellow
    Invoke-Expression $uninstallCommand
}

# Main script execution
if (!(Test-WingetInstalled)) {
    Write-Host "Winget is not installed. Please install winget and try again."
    exit
}
# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Display result
if (!($isAdmin)) {
    Write-Host "Please run this script as Administrator."
    exit
}

#########################################################################################
#########################################################################################
# 
# first cleanup
foreach ($package in $remove) {
    if (Test-WingetPackageInstalled -PackageId "$package"  -InstalledPackages $installedPackages) {
        Write-Host "$package is installed"
        Remove-Package $package
    }
    else {
        Write-Host "$package is not installed"
    }
}
function Disable-CapsLock {
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
    $valueName = "Scancode Map"
    $scancodeData = ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x3A,0x00,0x00,0x00,0x00,0x00))

    # Set the Scancode Map registry value
    New-ItemProperty -Path $registryPath -Name $valueName -PropertyType Binary -Value $scancodeData -Force

    Write-Output "Caps Lock key has been disabled. Please restart your computer for changes to take effect."
}

# Usage
Disable-CapsLock

#########################################################################################
# skip with -s
if (-not (Test-CommandLineOption "s")) {
    foreach ($package in $packages) {
        if ((-not (Test-WingetPackageInstalled -PackageId "$package"  -InstalledPackages $installedPackages)) -or (Test-CommandLineOption "f")) 
        {
            Install-Package $package
            Write-Host "$package is installed"
        } 
        else {
        }
    }
}

#$scriptPath = "C:\Users\uv\OneDrive\PowerShell"
$scriptPath = Split-Path -Path $PSCommandPath
Add-PathIfNotExist $scriptPath
Add-PathIfNotExist .
# Call the function after modifying PATH
Update-SessionEnvironment
# showPath
$env:Path
#
# scripts with additional steps
CheckTeraCopy
CreateAppVolumeLink
TurnOffDisplay

EnableNetworkDiscovery
# fix powershell config
CreatePowerShellLink
# wsl and virtualization
EnableExtraFeatures