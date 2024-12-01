# Create a symlink for the PowerShell Modules directory

# Define paths using environment variables
$linkPath = Join-Path -Path $home -ChildPath "Documents\PowerShell\Modules"
$targetPath = Join-Path -Path $home -ChildPath "OneDrive\PowerShell\Modules"

# Check if the symbolic link or item exists
if (Test-Path $linkPath) {
    $item = Get-Item $linkPath

    # Check if it's a symbolic link
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Output "Symbolic link already exists at $linkPath."
        return
    } else {
        # If it's not a symbolic link, try to remove it
        Write-Output "Removing existing non-symbolic link directory at $linkPath."
        try {
            Remove-Item -Path $linkPath -Recurse -Force
            Write-Output "Directory removed successfully."
        } catch {
            Write-Output "Error: Unable to remove directory at $linkPath. It may be in use or protected."
            Write-Output "Details: $_"
            # Exit script if directory cannot be removed
            return
        }
    }
}
# Create the symbolic link
Write-Output "Creating symbolic link from $linkPath to $targetPath."
New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath
