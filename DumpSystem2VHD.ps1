# Attempt to locate Disk2VHD in the system PATH with error handling
try {
    $disk2vhdPath = (Get-Command -Name disk2vhd64 -ErrorAction Stop | Select-Object -ExpandProperty Source)
    Write-Output "Disk2VHD found at: $disk2vhdPath"
} catch {
    Write-Output "Error: Disk2VHD64 not found in the system PATH. Please ensure Sysinternals is correctly installed."
    exit
}

# Define the destination folder and create a timestamped filename
$timestamp = (Get-Date).ToString("yyyy-MM-dd")
$outputFolder = "P:\VMs"
$outputVHDXName = "SystemImage_$timestamp.vhdx"
$outputVHDXPath = Join-Path -Path $outputFolder -ChildPath $outputVHDXName

# Verify that the output folder exists and is writable
if (-Not (Test-Path $outputFolder)) {
    Write-Output "Error: The specified output folder '$outputFolder' does not exist."
    exit
}
try {
    New-Item -Path $outputFolder -Name "test_write.txt" -ItemType "File" -Force | Out-Null
    Remove-Item "$outputFolder\test_write.txt" -Force
    Write-Output "Output folder '$outputFolder' is accessible and writable."
} catch {
    Write-Output "Error: Unable to write to the output folder '$outputFolder'. Check permissions."
    exit
}

# Define drives to include in the VHD (usually C: for the main OS)
$drivesToInclude = "C:"

# Run Disk2VHD with the specified parameters and check for completion
try {
    Write-Output "Running Disk2VHD to create VHDX image of the current system......"
    Write-Output "FilePath: $disk2vhdPath   ArgumentList: $drivesToInclude  OutputPath: $outputVHDXPath Options: -o -w -v -Wait"

    Start-Process -FilePath $disk2vhdPath -ArgumentList "$drivesToInclude $outputVHDXPath -o -w -v" -Wait
    Write-Output "VHDX creation completed successfully. VHDX saved at $outputVHDXPath"
} catch {
    Write-Output "Error: Failed to create VHDX. Check Disk2VHD execution and parameters."
    exit
}

# Check if VHDX file was created successfully
if (Test-Path $outputVHDXPath) {
    Write-Output "VHDX file created successfully at $outputVHDXPath"
} else {
    Write-Output "Error: VHDX file was not created. Please check Disk2VHD output for issues."
    exit
}

# Compress the VHDX file using Windows' built-in compression
$compressedPath = "$outputVHDXPath.zip"
Write-Output "Compressing the VHDX file to $compressedPath..."

try {
    # Using .NET's ZipFile class for compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory((Split-Path $outputVHDXPath), $compressedPath)
    Write-Output "Compression completed. Compressed file saved at $compressedPath"
} catch {
    Write-Output "Error: Compression failed. Check if .NET's System.IO.Compression is available."
}
