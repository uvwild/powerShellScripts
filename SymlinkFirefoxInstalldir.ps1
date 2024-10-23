# Define the default Firefox installation directory
$defaultInstallDir = "C:\Program Files\Mozilla Firefox"

# Define the Windows Store app installation directory for Firefox
$storeAppDir = "C:\Program Files\WindowsApps\Mozilla.Firefox_130.0.1.0_x64__n80bbvh6b1yt2"

# Check if the store app directory exists
if (-not (Test-Path -Path $storeAppDir)) {
    Write-Host "The specified Store app directory does not exist."
    exit
}

# Check if the default installation directory exists
if ( (Test-Path -Path $defaultInstallDir)) {
    Write-Host "The default installation directory $defaultInstallDir already  exists."
    exit
}


# Create the symbolic link
New-Item -Path $defaultInstallDir -ItemType SymbolicLink -Target $storeAppDir

Write-Host "Symlink created from $defaultInstallDir to $storeAppDir"
