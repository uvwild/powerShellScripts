$SourcePath = "C:\Users\uv\AppData\Roaming\Code\User\settings.json"
$TargetPath = "C:\Users\uv\OneDrive\PowerShell\settings.json"

# Check if the source path exists and is a file
if (Test-Path -Path $SourcePath -PathType Leaf -ErrorAction SilentlyContinue) {
    $link = Get-Item -Path $SourcePath

    # If the item is a symlink, but it points to a different target, remove it
    if ($link.PSIsContainer -eq $false -and $link.LinkType -eq 'SymbolicLink' -and $link.Target -ne $TargetPath) {
        Remove-Item -Path $SourcePath -Force
    } 
    # If the item is not a symlink, remove it
    elseif ($link.LinkType -ne 'SymbolicLink') {
        Remove-Item -Path $SourcePath -Force
    }
}

# Create the symbolic link only if it doesn't already exist
if (-not (Test-Path -Path $SourcePath -ErrorAction SilentlyContinue)) {
    New-Item -ItemType SymbolicLink -Path $SourcePath -Target $TargetPath
}