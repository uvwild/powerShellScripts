# Function to list all drive labels and their current letters
function Get-DriveLabels {
    Write-Host "Current Drive Labels and Letters:"
    Get-WmiObject -Query "SELECT Label, DriveLetter FROM Win32_Volume WHERE DriveLetter IS NOT NULL" | ForEach-Object {
        $label = $_.Label
        $letter = $_.DriveLetter
        if ($label) {
            Write-Host "Label: $label | Drive Letter: $letter"
        } else {
            Write-Host "Label: <No Label> | Drive Letter: $letter"
        }
    }
}

# Call the function to display drive labels and letters
Get-DriveLabels

# Define the list of drives with their target letters
$driveMap = @{
 #     "DriveLabel1" = "X";  # Example: Set drive labeled "DriveLabel1" to "X"
    # Add more as needed
}

# Function to assign drive letter based on volume label
function Set-DriveLetter {
    param (
        [string]$Label,
        [string]$TargetLetter
    )

    # Check if the target drive letter is already in use
    if (Get-PSDrive -Name $TargetLetter -ErrorAction SilentlyContinue) {
        Write-Host "Drive letter $TargetLetter is already in use."
        return
    }

    # Find the drive by label and set its letter
    $disk = Get-WmiObject -Query "SELECT * FROM Win32_Volume WHERE Label='$Label'" -ErrorAction SilentlyContinue
    if ($disk) {
        try {
            $disk.DriveLetter = $TargetLetter + ":"
            $disk.Put() | Out-Null
            Write-Host "Drive '$Label' assigned to $TargetLetter:"
        } catch {
            Write-Host "Failed to assign $TargetLetter to drive '$Label': $_"
        }
    } else {
        Write-Host "Drive with label '$Label' not found."
    }
}

# Iterate through each drive label and assign the target letter
foreach ($label in $driveMap.Keys) {
    Set-DriveLetter -Label $label -TargetLetter $driveMap[$label]
}
