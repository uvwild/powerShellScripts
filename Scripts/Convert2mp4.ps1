# Convert2mp4
# create shortcut like this
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\uv\OneDrive\PowerShell\Scripts\Convert2mp4.ps1"
# script to convert
# Get the path to FFmpeg using Get-Command
$deleteOriginal = $true
$ffmpegPath = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source

if (-not $ffmpegPath) {
    Write-Host "FFmpeg not found in PATH. Please ensure FFmpeg is installed and added to your system PATH."
    exit
}

# Function to convert video
function Check-Files {
    param (
        [string]$inputFile,
        [string]$outputFile
    )

    # Check if the output file was created successfully
    if (Test-Path $outputFile) {
        if ($fileSize -eq 0) {
            Remove-Item $outputFile
            Write-Host "the output file is empty and will be replaced: $outputFile"
        }
        elseif ($fileSize -lt $limit) {
            # Ask if the user wants to delete the original file
            $deletePrevious = Read-Host "There is an outputfile smaller than  $limit already do you want to replace it? (y/n): $outputFile"
            if ($deletePrevious -eq 'y') {
                Remove-Item $inputFile
                Write-Host "Previous file deleted."
            }
            else {
                Write-Host "Previous file found : $outputFile   -  SKIPPING"
                return
            }
        }
    }

}
# Function to convert video with crop detection    
$limit = 1MB
function Convert-VideosWithCropDetection {
    param (
        [string]$inputFile
    )

    # Output file path
    $outputFile = [System.IO.Path]::ChangeExtension($inputFile, ".mp4")
    Check-Files ($inputFile, $outputFile)

    # Step 1: Detect crop values
    Write-Output "looking for crop values in $inputFile"  -foregroundcolor "yellow"
    $cropDetectCommand = "ffmpeg -i `"$inputFile`" -vf cropdetect -t 10 -f null NUL 2>&1"
    $cropOutput = Invoke-Expression $cropDetectCommand

    # Extract the crop values from the cropdetect output
    $cropOption = ""
    if (($cropOutput -match "crop=\d+:\d+:\d+:\d+") -and ($matches))  {
        $cropValues = $matches[0]
        Write-Output "Detected crop values: $cropValues"
        
        # Step 2: Apply cropping and convert video
        $cropOption = "-vf `"$cropValues`" "
        Write-Host "Converting and cropping video..."
    }
    else {
        Write-Output "Could not detect crop values for $inputFile. No Cropping."        
    }
    $ffmpegCommand = "ffmpeg -i `"$inputFile`" $cropOption -c:v libx264 -preset fast -crf 23  -c:a aac `"$outputFile`""
    Invoke-Expression $ffmpegCommand

    # Check if the output file was created successfully
    if (Test-Path $outputFile) {
        Write-Host "Conversion complete. Output file: $outputFile"
        
        if ($deleteOriginal) {
            Write-Host "Original file deleted."
        }
        else {
            # Ask if the user wants to delete the original file
            $deleteOriginal = Read-Host "Do you want to delete the original file? (y/n)"
            if ($deleteOriginal -eq 'y') {
                Remove-Item $inputFile
                Write-Host "Original file deleted."
            }
            else {
                Write-Host "Original file kept."
            }

        }
    }
    else {
        Write-Host "Conversion failed. Please check the FFmpeg output for errors."
    }
}

function Start-ConversionOnLowLoad {
    while ($true) {
        $cpuLoad = (Get-WmiObject -Query "SELECT LoadPercentage FROM Win32_Processor").LoadPercentage | Measure-Object -Average | Select-Object -ExpandProperty Average
        
        if ($cpuLoad -lt 10) {
            Write-Output "CPU load is below 10%. Waiting for 30 minutes to confirm stability."
            Start-Sleep -Seconds 1800

            $cpuLoadAfterWait = (Get-WmiObject -Query "SELECT LoadPercentage FROM Win32_Processor").LoadPercentage | Measure-Object -Average | Select-Object -ExpandProperty Average
            
            if ($cpuLoadAfterWait -lt 10) {
                Write-Output "CPU load is still below 10% after 30 minutes. Starting video conversion."
                Get-ChildItem -Path $InputFolder -Filter *.mp4 | ForEach-Object {
                    Convert-VideosWithCropDetection -inputFile $_.FullName
                }
                break
            }
            else {
                Write-Output "CPU load increased above 10% after waiting. Restarting monitoring."
            }
        }
        else {
            Write-Output "CPU load is above 10%. Monitoring continues."
        }

        Start-Sleep -Seconds 300 # Check every 5 minutes
    }
}

# Example usage
# TODO find a way to deal with the folder parameters
#Start-ConversionOnLowLoad -InputFolder "C:\Videos\Input" -OutputFolder "C:\Videos\Output"


$videoExtensions = ( ".m2ts", ".wmv", ".mpg" , ".3gp" )
# Check if script is being run with a file drop
if ($args.Count -eq 0) {
    Write-Host "Please drag and drop a .m2ts file onto this script."
}
else {
    foreach ($file in $args) {

        if (Test-Path $file) {
            foreach ($extension in $videoExtensions) { 
                if ([System.IO.Path]::GetExtension($file) -eq "$extension") {
                    Write-Output "Found ${file} with  extension ${extension}. Converting..."
                    #Convert-Video -inputFile $file
                    Convert-VideosWithCropDetection -inputFile "$file"
                }
            }
        }
        else {
            Write-Output "File does not exist."
        }
    }
}    


#Write-Host "Press any key to exit..."
#$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
