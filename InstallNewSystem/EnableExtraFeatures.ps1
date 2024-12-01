# Run this script as Administrator
# Enable Virtualization in BIOS/UEFI (Note: This part can't be automated in PowerShell; enable it in BIOS if disabled)

# list of features
$featureList = @(
    "Microsoft-Hyper-V-All",
    "VirtualMachinePlatform",
    "Microsoft-Windows-Subsystem-Linux",
    ""
)
function Check-And-EnableFeatureStatus {
    param (
        [string]$FeatureName
    )
    $feature = Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq $FeatureName }
    
    if ($feature.State -eq 'Enabled') {
        Write-Host "$FeatureName is already enabled."  -ForegroundColor Yellow
    } else {
        Write-Host "$FeatureName is not enabled. Enabling now..."  -ForegroundColor Red
        Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart
        Write-Host "$FeatureName has been enabled." -ForegroundColor Green
    }
}

foreach ($featureName in $featureList) {
    if ($featureName) { 
        Check-And-EnableFeatureStatus($featureName)
    }
}


# Enable WSL 2 as the default version
Write-Output "Setting WSL 2 as the default version..."
wsl --set-default-version 2

# Reboot to apply changes
#Write-Output "All features enabled. Restarting your computer to apply changes..."
#Restart-Computer
$reboot = Read-Host "All features enabled. Do you want to reboot now? (Y/N)"
if ($reboot -match '^[Yy]$') {
    Restart-Computer
}
