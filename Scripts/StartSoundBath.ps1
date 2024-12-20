#StartSoundBath.ps1

# get list of audio devices
Install-Module -Name AudioDeviceCmdlets -Scope CurrentUser -Force
$audioDevices = Get-AudioDevice -List
# $audioDevices | ForEach-Object {
#     Write-Host "Name: $($_.Name)"
#     Write-Host "Type: $($_.Type)"
#     Write-Host "Device ID: $($_.Id)"
#     Write-Host "----------------------"
# }

# find the one with Studio 24c
$studio24cDevice = $audioDevices | Where-Object { $_.Name -like "*Studio 24c*" }

# specify the audio file
$audioFile = "C:\Users\uv\Music\Moods\174Hz _ Pain Relief Pure Tone Sleep Music _ DEEPEST Healing Solfeggio Frequency on the Planet.mp3"

# use this information to set parameters to start vlc with a mp3 file
if ($studio24cDevice) {
    $deviceId = $studio24cDevice.Id
    Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" -ArgumentList "--aout=directsound --directx-audio-device=$deviceId", $audioFile
} else {
    Write-Host "No audio device with 'Studio 24c' found."
}