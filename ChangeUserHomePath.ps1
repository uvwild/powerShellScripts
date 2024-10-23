## change the homepath of a user in windows. rather dont use it!!!
# @uv 2024-oct
# Function to log messages to a log file
function Write-Log {
    param (
        [string]$message,
        [string]$logFile = "$env:USERPROFILE\Documents\UserFolderUpdateLog.txt"
    )

    # Add timestamp to log entries
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    
    # Write to console and log file
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Function to simulate or execute actions based on the -x flag
function Update-UserFolderAndRegistry {
    param(
        [string]$oldPath = "C:\Users\uvlig",
        [string]$newPath = "C:\Users\uvzen",
        [switch]$execute,  # -x flag to execute the actions
        [string]$logFile = "$env:USERPROFILE\Documents\UserFolderUpdateLog.txt"
    )

    # Step 1: Rename the user folder (simulation or execution based on the flag)
    if ($execute) {
        try {
            Rename-Item -Path $oldPath -NewName $newPath
            Write-Log "Renamed user folder from $oldPath to $newPath" -logFile $logFile
        } catch {
            Write-Log "Error renaming user folder: $_" -logFile $logFile
            return
        }
    } else {
        Write-Log "[SIMULATION] Would rename user folder from $oldPath to $newPath" -logFile $logFile
    }

    # Step 2: Update registry locations (simulation or execution based on the flag)
    $registryKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
    )

    foreach ($key in $registryKeys) {
        try {
            $values = Get-ItemProperty -Path $key
            foreach ($name in $values.PSObject.Properties.Name) {
                if ($values.$name -like "*$oldPath*") {
                    $newValue = $values.$name -replace [regex]::Escape($oldPath), $newPath

                    if ($execute) {
                        Set-ItemProperty -Path $key -Name $name -Value $newValue
                        Write-Log "Updated $name in $key from $oldPath to $newPath" -logFile $logFile
                    } else {
                        Write-Log "[SIMULATION] Would update $name in $key from $oldPath to $newPath" -logFile $logFile
                    }
                }
            }
        } catch {
            Write-Log "Error accessing registry key $key: $_" -logFile $logFile
        }
    }

    # Step 3: Search registry for any leftover references to the old path
    Write-Log "Searching for any leftover references to $oldPath in the registry..." -logFile $logFile
    Get-ChildItem -Path HKLM:\,HKCU:\ -Recurse | ForEach-Object {
        try {
            $values = Get-ItemProperty -Path $_.PSPath
            foreach ($name in $values.PSObject.Properties.Name) {
                if ($values.$name -like "*$oldPath*") {
                    if ($execute) {
                        Write-Log "Found reference in $_.PSPath: $name = $($values.$name)" -logFile $logFile
                    } else {
                        Write-Log "[SIMULATION] Found reference in $_.PSPath: $name = $($values.$name)" -logFile $logFile
                    }
                }
            }
        } catch {
            # Ignore errors accessing certain registry keys
        }
    }

    Write-Log "Completed the process." -logFile $logFile
}

# Parse command line arguments
param (
    [switch]$x  # If -x is provided, execute the actions
)

# Define the log file path
$logFilePath = "$env:USERPROFILE\Documents\UserFolderUpdateLog.txt"

# Call the function to update the user folder path and registry entries, passing the -x flag if provided
if ($x) {
    Update-UserFolderAndRegistry -execute -logFile $logFilePath
} else {
    Update-UserFolderAndRegistry -logFile $logFilePath
}

Write-Log "Script execution finished." -logFile $logFilePath
