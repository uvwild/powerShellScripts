# Function to search for the token "uvlig" in the registry
function Search-RegistryForToken {
    param (
        [string]$token = "uvlig",
		[string]$newToken = "uvzen"
    )

    $hives = "HKLM", "HKCU", "HKCR", "HKU", "HKCC"

    foreach ($hive in $hives) {
        Write-Host "Searching in $hive..."

        # Searching keys, values, and data for the token
        Get-ChildItem "Registry::$hive" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $key = $_.PSPath
				Write-Host "`r$key" -ForegroundColor green -NoNewLine
                
				 if ($key -match "CLasses") {
					continue  # Skip this iteration
				}		

                # Search in the name and data of each registry entry
                $entries = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
                foreach ($entry in $entries.PSObject.Properties) {
                    if ($entry.Name -like "*$token*" -or $entry.Value -like "*$token*") {
						Write-Host "`r"
                        Write-Host "Found $token in $key -> $($entry.Name): $($entry.Value)"  -ForegroundColor red
						if (false) {
							# Replace the old token with the new one
							$newValue = $entry.Value -replace $oldToken, $newToken
							Set-ItemProperty -Path $path -Name $entry.Name -Value $newValue
							Write-Host "Replaced $oldToken with $newToken in $path -> $($entry.Name)"
						}
			
                    }
                }
            } catch {
                # Handle access denied errors or other exceptions
                Write-Host "Error accessing $key"
            }
        }
    }
}

# Call the function
Search-RegistryForToken "uvlig"
