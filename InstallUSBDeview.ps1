#installUSBDeview.ps1
# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $1
Start-Sleep -Seconds 3
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
Write-Host "Script is running with administrative privileges." -ForegroundColor Green


# Download and set up USBDeview
$usbDeviewUrl = "https://www.nirsoft.net/utils/usbdeview-x64.zip"
$usbDeviewZip = "$env:Temp\usbdeview-x64.zip"
$usbDeviewPath = "$env:ProgramFiles\USBDeview"

# Check if USBDeview is already installed
if (Test-Path $usbDeviewPath) {
    Write-Host "USBDeview is already installed at $usbDeviewPath. Skipping installation..." -ForegroundColor Yellow
} else {
    # Download USBDeview
    Invoke-WebRequest -Uri $usbDeviewUrl -OutFile $usbDeviewZip

    # Extract the files
    Expand-Archive -Path $usbDeviewZip -DestinationPath $usbDeviewPath -Force

    # Add to PATH (optional)
    [Environment]::SetEnvironmentVariable("Path", "$($env:Path);$usbDeviewPath", [EnvironmentVariableTarget]::Machine)

    Write-Host "USBDeview installed at $usbDeviewPath"
}

# Start USBDeview
$usbDeviewExe = "$usbDeviewPath\USBDeview.exe"
if (Test-Path $usbDeviewExe) {
    Start-Process -FilePath $usbDeviewExe
    Write-Host "USBDeview started successfully." -ForegroundColor Green
} else {
    $1
Start-Sleep -Seconds 3
    
}
