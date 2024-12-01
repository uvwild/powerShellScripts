# Get the path to FFmpeg using Get-Command
$ffmpegPath = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source

if (-not $ffmpegPath) {
    Write-Host "FFmpeg not found in PATH. Please ensure FFmpeg is installed and added to your system PATH."
    exit
}

# Function to convert video
function Convert-Video {
    param (
        [string]$inputFile
    )

    # Output file path
    $outputFile = [System.IO.Path]::ChangeExtension($inputFile, ".mp4")

    # FFmpeg command with 15 seconds cut from the start
    $ffmpegCommand = "& `"$ffmpegPath`" -ss 00:00:15 -i `"$inputFile`" -c:v libx264 -preset slow -crf 22 `"$outputFile`""
    
    # Execute FFmpeg command
    Write-Host "Converting and trimming video..."
    Invoke-Expression $ffmpegCommand

    # Check if the output file was created successfully
    if (Test-Path $outputFile) {
        Write-Host "Conversion complete. Output file: $outputFile"
        
        # Ask if the user wants to delete the original file
        $deleteOriginal = Read-Host "Do you want to delete the original file? (y/n)"
        if ($deleteOriginal -eq 'y') {
            Remove-Item $inputFile
            Write-Host "Original file deleted."
        } else {
            Write-Host "Original file kept."
        }
    } else {
        Write-Host "Conversion failed. Please check the FFmpeg output for errors."
    }
}

# Check if script is being run with a file drop
if ($args.Count -eq 0) {
    Write-Host "Please drag and drop a .m2ts file onto this script."
} else {
    foreach ($file in $args) {
        if ([System.IO.Path]::GetExtension($file) -eq ".m2ts") {
            Convert-Video -inputFile $file
        } else {
            Write-Host "Skipping non-.m2ts file: $file"
        }
    }
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
