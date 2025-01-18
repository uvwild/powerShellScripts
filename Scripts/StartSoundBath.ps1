# StartSoundBath.ps1
[CmdletBinding()]

param (
    [Alias("v")]
    [switch]$ShowDetails
)

$audioDevice="Studio 24"
# Specify the audio file
$mp3File='C:\\Users\\uv\\Music\\Moods\\174Hz _ Pain Relief Pure Tone Sleep Music _ DEEPEST Healing Solfeggio Frequency on the Planet.mp3'

# Check if ffmpeg is installed
$ffmpegPath = "ffmpeg"
if (!(Get-Command $ffmpegPath -ErrorAction SilentlyContinue)) {
    Write-Error "FFmpeg is not installed or not in PATH. Please install it before running this script."
    exit 1
}

# Get a list of audio devices
$devices = & $ffmpegPath -list_devices true -f dshow -i dummy 2>&1 |
Select-String -Pattern "dshow"  |
  ForEach-Object {1
      if ($_ -like "*$audioDevice*") {
          $_
      }
  }
# Display the devices
Write-Output "Available audio devices:"
#$devices | ForEach-Object { Write-Output $_ }

# Find the device matching the name "Studio 24"
$selectedDevice = $devices | Where-Object { $_ -like "*Speaker*Studio 24*" } | Select-Object -First 1

if (-not $selectedDevice) {
    Write-Error "No audio device containing 'Studio 24' found."
    exit 1
}

Write-Output "Selected audio device: $selectedDevice"

# Play the MP3 file in a loop using the selected audio device
& $ffmpegPath -re -stream_loop -1 -i $mp3File -acodec pcm_s16le -ar 44100 -ac 2 -filter_complex "aresample=async=1" -y -f dshow "audio=$selectedDevice"
