#CheckUSBDevices.ps1
# Check if the current user has administrative rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrative privileges. Please run as Administrator." -ForegroundColor Red
    exit 1
} else {
    Write-Host "Administrative privileges confirmed. Proceeding..." -ForegroundColor Green
}

# Download and set up USBDeview
$usbDeviewUrl = "https://www.nirsoft.net/utils/usbdeview-x64.zip"
$usbDeviewZip = "$env:Temp\usbdeview-x64.zip"
$usbDeviewPath = "$env:ProgramFiles\USBDeview"

# Download USBDeview
Invoke-WebRequest -Uri $usbDeviewUrl -OutFile $usbDeviewZip

# Extract the files
Expand-Archive -Path $usbDeviewZip -DestinationPath $usbDeviewPath -Force

# Add to PATH (optional)
[Environment]::SetEnvironmentVariable("Path", "$($env:Path);$usbDeviewPath", [EnvironmentVariableTarget]::Machine)

Write-Host "USBDeview installed at $usbDeviewPath"
