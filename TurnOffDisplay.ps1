# display off
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

$shortcutPath = "$env:USERPROFILE\Desktop\TurnOffDisplay.lnk"
$targetPath = "powershell.exe"
$arguments = '-WindowStyle Hidden -Command "(Add-Type ''[DllImport(\"user32.dll\")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);'' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)"'

$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Arguments = $arguments
$shortcut.IconLocation = "C:\Windows\System32\DisplaySwitch.exe,0"
$shortcut.Save()

Write-ColorOutput "Shortcut created on desktop: $shortcutPath"  -Color Green
