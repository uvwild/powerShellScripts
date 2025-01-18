#join 2 videos

$files = @(
    # "C:\Users\uv\Videos\OBS\2025-01-04 05-27-55.mp4",
    # "C:\Users\uv\Videos\OBS\2025-01-04 05-39-16.mp4"
    #"C:\Users\uv\Videos\OBS\2025-01-04 06-29-51.mp4",
    #"C:\Users\uv\Videos\OBS\2025-01-04 06-40-07.mp4"
    # "C:\Users\uv\Videos\2025-01-04 06-40-07.mp4",
    # "C:\Users\uv\Videos\2025-01-04 05-39-16.mp4",
    # "C:\Users\uv\Videos\2025-01-04 06-29-51.mp4",
    # "C:\Users\uv\Videos\2025-01-04 06-40-07.mp4"
    # "C:\Users\uv\Videos\OBS\2025-01-12 04-44-28.mp4",
    # "C:\Users\uv\Videos\OBS\2025-01-12 04-51-24.mp4"
    "C:\Users\uv\Videos\OBS\2025-01-12 18-52-14.mp4",
    "C:\Users\uv\Videos\OBS\2025-01-12 06-36-24.mp4"
)

$combinedOutputFile =  "T:\Videos\RubberPassion\Lola Fucking Toy-2023.mp4"
#$combinedOutputFile =  "T:\Videos\RubberPassion\CumSlut-2012.mp4"
#$combinedOutputFile =  "T:\Videos\RubberPassion\Naughty_Lucy_Explores-2009.mp4"
#$combinedOutputFile =  "T:\Videos\RubberPassion\Naughty_Nun-2023.mp4"
if (Test-Path $combinedOutputFile) {
    $fileSize = (Get-Item -Path $combinedOutputFile).Length
    write-host "file $combinedOutputFile already exists File size: $fileSize" -ForegroundColor Yellow
    dir $combinedOutputFile
    Read-Host "Press Enter to continue"
    rm $combinedOutputFile
}
$listPath = "file_list.txt"
Set-Content -Path $listPath -Value ""

foreach ($file in $files) {
    if ([System.IO.Path]::GetExtension($file) -ieq ".mp4") {
        write-host "file $file is already an mp4 file" -ForegroundColor Yellow
        $outputFile=$file   
    }
    else {
        write-host "file $file is not an mp4 file. converting" -ForegroundColor red
        $outputFile = [System.IO.Path]::ChangeExtension($file, ".mp4")
        ffmpeg -i $file -c:v libx264 -preset fast -crf 23 -c:a aac $outputFile    
    }
    Add-Content -Path $listPath -Value "file '$outputFile'"
}
ffmpeg -f concat -safe 0 -i $listPath -c copy $combinedOutputFile
