# Function to replace "uvlig" with "uvzen" in the registry at specified locations
function Replace-TokenInRegistry {
    param (
        [string[]]$paths,   # List of registry paths to modify
        [string]$oldToken = "uvlig",
        [string]$newToken = "uvzen"
    )

    foreach ($path in $paths) {
        try {
            $entries = Get-ItemProperty -Path $path -ErrorAction Stop

            foreach ($entry in $entries.PSObject.Properties) {
                if ($entry.Value -like "*$oldToken*") {
                    # Replace the old token with the new one
                    $newValue = $entry.Value -replace $oldToken, $newToken
                    Set-ItemProperty -Path $path -Name $entry.Name -Value $newValue
                    Write-Host "Replaced $oldToken with $newToken in $path -> $($entry.Name)"
                }
            }
        } catch {
            Write-Host "Error modifying $path"
        }
    }
}

# Example usage (provide your list of paths after review)
$pathsToModify = @(
    "HKCU\Software\ExamplePath1",
    "HKLM\Software\ExamplePath2"
)

Replace-TokenInRegistry -paths $pathsToModify
