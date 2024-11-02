
#InstallNewSystem

# Define the list of packages to install
$packages = @(
    # windows
    "Microsoft.PowerShell",
    "Microsoft.PowerToys",
    "Microsoft.Sysinternals",
    "CodeSector.TeraCopy",
    "HermannSchinagl.LinkShellExtension",
    
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
    "GlavSoft.TightVNC 2.8.85",

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
    "7zip.7zip",
    "JAMSoftware.TreeSize.Free",
    "Notepad++.Notepad++",
    "IrfanSkiljan.IrfanView",
    "IrfanSkiljan.IrfanView.PlugIns",
    "CodeSector.TeraCopy",
    "ScooterSoftware.BeyondCompare.5",
    "TheDocumentFoundation.LibreOffice"
)

# Function to check if a package is already installed
function Is-PackageInstalled($packageName) {
    return (winget list --name $packageName | Out-String).Trim() -ne ""
}

# Install packages with error handling and retry mechanism
foreach ($package in $packages) {
    if (-not (Is-PackageInstalled $package)) {
        $retryCount = 3
        for ($i = 1; $i -le $retryCount; $i++) {
            Write-Host "Installing $package (Attempt $i of $retryCount)..."
            winget install --id $package --accept-source-agreements --silent
            if (Is-PackageInstalled $package) {
                Write-Host "$package installed successfully."
                break
            } elseif ($i -eq $retryCount) {
                Write-Host "Failed to install $package after $retryCount attempts."
            }
            Start-Sleep -Seconds 5  # Brief wait before retry
        }
    } else {
        Write-Host "$package is already installed, skipping..."
    }
}

# Remove unnecessary packages
$remove = @("Xbox", "MicrosoftTeams")
foreach ($package in $remove) {
    Write-Host "Attempting to remove $package..."
    winget uninstall --id $package --silent
}

# Optional reboot function
function Prompt-Reboot {
    $response = Read-Host "Some installations may require a reboot. Do you want to reboot now? (y/n)"
    if ($response -eq "y") {
        Restart-Computer -Force
    } else {
        Write-Host "Reboot skipped. Note: Some changes may not take effect until next reboot."
    }
}

# Placeholder for configuration setup (customize as needed)
# Configure VS Code (import settings file if exists)
# Configure Git (global configs)
# Configure PowerShell (profile customizations)

Write-Host "Setup complete. Review above output for any errors."

# Prompt for reboot if needed
Prompt-Reboot
