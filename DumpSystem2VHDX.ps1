# Attempt to locate Disk2VHD executable dynamically
$disk2vhdPath = Get-Command disk2vhd64.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

# If the executable is not found, prompt an error and exit
if (-not $disk2vhdPath) {
    Write-Output "Error: Disk2VHD executable not found. Ensure it is installed via winget and available in the system PATH, or specify the full path manually."
    exit
} else {
    Write-Output "Found Disk2VHD at: $disk2vhdPath"
}

# Confirming 64-bit PowerShell session to avoid file redirection issues
if ($env:PROCESSOR_ARCHITECTURE -ne "AMD64") {
    Write-Output "Error: Please run this script in 64-bit PowerShell to avoid architecture conflicts."
    exit
}

# Define the destination folder and create a timestamped filename
$timestamp = (Get-Date).ToString("yyyy-MM-dd")
$outputFolder = "P:\VMs"
$outputVHDXName = "SystemImage_$timestamp.vhdx"
$outputVHDXPath = Join-Path -Path $outputFolder -ChildPath $outputVHDXName

# Verify that the output folder exists and is writable
if (-Not (Test-Path $outputFolder)) {
    Write-Output "Error: The specified output folder '$outputFolder' does not exist. Please create the folder or check the path."
    exit
}
try {
    New-Item -Path $outputFolder -Name "test_write.txt" -ItemType "File" -Force | Out-Null
    Remove-Item "$outputFolder\test_write.txt" -Force
    Write-Output "Output folder '$outputFolder' is accessible and writable."
} catch {
    Write-Output "Error: Unable to write to the output folder '$outputFolder'. Check permissions or run the script as Administrator."
    exit
}

# Define drives to include in the VHD (usually C: for the main OS)
$drivesToInclude = "C:"

# Define additional options for Disk2VHD command
$disk2vhdOptions = "-h" # , "-w", "-v"  # Add any additional options here

# Construct the full command line string for logging or troubleshooting purposes
$disk2vhdCommand = "`"$disk2vhdPath`" $drivesToInclude `"$outputVHDXPath`" $($disk2vhdOptions -join ' ')"
Write-Output "Disk2VHD command line: $disk2vhdCommand"

# Run Disk2VHD with specified parameters using Start-Process and separate arguments
try {
    Write-Output "Running Disk2VHD to create VHDX image of the current system..."
    Start-Process -FilePath $disk2vhdPath -ArgumentList $drivesToInclude, $outputVHDXPath + $disk2vhdOptions -Wait
    Write-Output "VHDX creation completed successfully. VHDX saved at $outputVHDXPath"
} catch {
    Write-Output "Error: Failed to create VHDX. Possible causes:"
    Write-Output "- Disk2VHD may require Administrator privileges to access the specified drives."
    Write-Output "- Check if the drive is available and accessible."
    Write-Output "- Ensure there is sufficient space in the output directory."
    Write-Output "- Confirm that Disk2VHD parameters are valid and supported."
    exit
}

# Check if VHDX file was created successfully
if (Test-Path $outputVHDXPath) {
    Write-Output "VHDX file created successfully at $outputVHDXPath"
} else {
    Write-Output "Error: VHDX file was not created. Check Disk2VHD output and parameters for potential issues."
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
    Write-Output "Error: Compression failed. Possible causes:"
    Write-Output "- Insufficient permissions or lack of write access to the output directory."
    Write-Output "- Ensure .NET's System.IO.Compression is available."
    Write-Output "- Check disk space and try again."
}
