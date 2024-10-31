# CreateAppVolumeLink

function Write-ColorOutput {
    param(
        [string]$Text,
        [System.ConsoleColor]$Color = [System.ConsoleColor]::Red
    )
    $originalColor = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Text
    $host.UI.RawUI.ForegroundColor = $originalColor
}

$Desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = "$Desktop\AppVolumes.lnk"
$targetPath = "ms-settings:apps-volume"
$arguments = ""

$folderPath = "C:\Example\Folder"
if (Test-Path -Path $folderPath) {
    Write-Host "The folder exists"
} else {
    Write-Host "The folder does not exist"
}

$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Arguments = $arguments
$Shortcut.Save()

Write-ColorOutput "Shortcut created on desktop: $shortcutPath"  -Color Green
