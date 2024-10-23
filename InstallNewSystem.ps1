#InstallNewSystem
# Define the list of packages to install
$packages = @(
	# windows
    "Microsoft.PowerShell",
    "Microsoft.PowerToys",
    "Microsoft.Sysinternals",
    "CodeSector.TeraCopy",
	
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
    "Genymobile.scrcpy",
    "Frontesque.scrcpy+",
	
	# audio
    "Audacity.Audacity",
		
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
    "MusicBee.MusicBee",
    "GianlucaPernigotto.Videomass",

	# browser mail
    "Google.Chrome",
    "Mozilla.Firefox",
    "Mozilla.Thunderbird",
    "Mailbird.Mailbird",
	
	# util
    "7zip.7zip",
    "Notepad\+\+.Notepad\+\+",
    "CodeSector.TeraCopy",
    "ScooterSoftware.BeyondCompare.5",
	"" # to keep the last comma
)

$remove = @(
    "Xbox",
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
function Check-WingetInstalled {
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

function Test-WingetPackageInstalled {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageId,
        [Parameter(Mandatory = $true)]
        [array]$InstalledPackages
    )
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
    
    if ($silentInstall) {
        $installCommand += " --silent"
    }
  
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
    $installCommand = "winget remove $packageName"
    Write-Host "Removing $packageName..." -ForegroundColor Red
    Write-Host "$installCommand"   -ForegroundColor Blue
    Invoke-Expression $installCommand
}

# Main script execution
if (!(Check-WingetInstalled)) {
    Write-Host "Winget is not installed. Please install winget and try again."
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

$scriptPath = "C:\Users\uv\OneDrive\OneDriveDocuments\PowerShell"
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
