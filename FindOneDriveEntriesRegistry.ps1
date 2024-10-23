# FindOneDriveEntriesRegistry.ps1
# Define the registry paths to search
$paths = @(
    "HKCU:\Software\Microsoft\OneDrive",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders",
    "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\General",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive",
    "HKCU:\SOFTWARE\Policies\Microsoft\OneDrive"
)

# Function to recursively get registry keys and values
function Get-RegistryItems {
    param (
        [string]$Path
    )
    
    if (Test-Path $Path) {
        Get-ChildItem $Path -Recurse | ForEach-Object {
            $key = $_
            if ($key.ValueCount -gt 0) {
                Get-ItemProperty -Path $key.PSPath | ForEach-Object {
                    foreach ($value in $_.PSObject.Properties) {
                        if ($value.Name -notmatch '^(PSPath|PSParentPath|PSChildName|PSDrive|PSProvider)$') {
                            [PSCustomObject]@{
                                Key = $key.Name
                                ValueName = $value.Name
                                ValueData = $value.Value
                            }
                        }
                    }
                }
            }
        }
    }
}

# Search for OneDrive-related entries in the specified paths
$results = foreach ($path in $paths) {
    Get-RegistryItems -Path $path | Where-Object {
        $_.Key -like "*OneDrive*" -or
        $_.ValueName -like "*OneDrive*" -or
        $_.ValueData -like "*OneDrive*"
    }
}

# Display the results
$results | Format-Table -AutoSize

# Optionally, export results to a CSV file
# $results | Export-Csv -Path "OneDriveRegistryEntries.csv" -NoTypeInformation
