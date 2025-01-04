# CreatePornFoxLink

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

$ShortcutPath = Join-Path ([Environment]::GetFolderPath('Desktop')) "PornFox.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
$shortcut.Arguments = ' -P "porn" -no-remote'
$Shortcut.IconLocation = "C:\Users\uv\OneDrive\Pictures\pornfox.ico"
$Shortcut.Save()

Write-ColorOutput "Shortcut created on desktop: $shortcutPath"  -Color Green

