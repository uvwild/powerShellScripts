# Explicitly define the 64-bit Disk2VHD path to avoid architecture conflicts
$disk2vhdPath = "C:\Program Files\SysinternalsSuite\disk2vhd64.exe"


# Check if Disk2VHD exists
if (-not (Test-Path $disk2vhdPath)) {
    Write-Error "Disk2VHD not found at $disk2vhdPath. Please provide the correct path."
    exit
}

# Generate timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

# Set the output path for the VHD file with timestamp
$outputPath = "D:\VirtualMachines\Windows11_Master_$($timestamp.Replace(':', '-')).vhdx"

# Run Disk2VHD to create the VHDX file
$arguments = @(
    "-c",  # Use compression
    "-o",  # Optimize the VHD for virtual machine use
    $outputPath,
    "C:"
)

Start-Process -FilePath $disk2vhdPath -ArgumentList $arguments -Wait

Write-Host "Virtual disk image creation complete. File saved to: $outputPath"
