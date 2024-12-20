# StartSoundBath.ps1
[CmdletBinding()]

param (
    [Alias("v")]
    [switch]$ShowDetails
)

# Install the AudioDeviceCmdlets module if not already installed
Install-Module -Name AudioDeviceCmdlets -Scope CurrentUser -Force

function Show-AudioDeviceProperties {
    param (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSObject]$audioDevice
    )

    Write-Host "Device: $($audioDevice.Name)" -ForegroundColor Cyan
    $audioDevice | Get-Member -MemberType Properties | ForEach-Object {
        $propertyName = $_.Name
        $propertyValue = $audioDevice.$propertyName
        Write-Host -ForegroundColor Blue -NoNewline "${propertyName}: "
        Write-Host -ForegroundColor Yellow "$propertyValue"
    }
    Write-Host "----------------------" -ForegroundColor Green
}

# Get list of audio devices
$audioDevices = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' }
Write-Host "Retrieved list of playback audio devices." -ForegroundColor Green

# Show properties of all audio devices if -ShowDetails is provided
if ($ShowDetails) {
    $audioDevices | ForEach-Object {
        Show-AudioDeviceProperties -audioDevice $_
    }
}

# Find the device with Studio 24c
$studio24cDevice = $audioDevices | Where-Object { $_.Name -like "*Studio 24c*" }

# Specify the audio file
$audioFile = 'C:\\Users\\uv\\Music\\Moods\\174Hz _ Pain Relief Pure Tone Sleep Music _ DEEPEST Healing Solfeggio Frequency on the Planet.mp3'

# Log the audio file to be used
Write-Host "Using audio file: $audioFile." -ForegroundColor Green

# Use this information to set parameters to start VLC with the mp3 file
if ($studio24cDevice) {
    # Get the numeric index of the Studio 24c device
    $deviceIndex = [int]$studio24cDevice.Index
    Write-Host "[$(Get-Date)] Found Studio 24c device with index: $deviceIndex." -ForegroundColor Green

    # Start VLC with the specified audio file
    Start-Process "C:\\Program Files\\VideoLAN\\VLC\\vlc.exe" -ArgumentList "--aout=directsound", "--directx-audio-device=$deviceIndex", "`"$audioFile`""
    Write-Host "Started VLC with the specified audio file." -ForegroundColor Green
} else {
    Write-Host "No audio device with 'Studio 24c' found." -ForegroundColor Red
}