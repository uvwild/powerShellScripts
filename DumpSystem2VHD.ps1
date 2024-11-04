# Explicitly define the 64-bit Disk2VHD path to avoid architecture conflicts
$disk2vhdPath = "C:\Program Files\SysinternalsSuite\disk2vhd64.exe"

# Confirming 64-bit PowerShell session to avoid file redirection issues
if ($env:PROCESSOR_ARCHITECTURE -ne "AMD64") {
    Write-Output "Please run this script in 64-bit PowerShell to avoid architecture conflicts."
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

# Run Disk2VHD with corrected parameters for a basic setup
try {
    Write-Output "Running Disk2VHD to create VHDX image of the current system..."
    Start-Process -FilePath $disk2vhdPath -ArgumentList "$drivesToInclude", "$outputVHDXPath", "-o", "-w", "-v" -Wait
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
