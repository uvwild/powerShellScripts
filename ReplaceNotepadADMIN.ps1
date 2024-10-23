# replace windows notepad with a good one
# uv@2024
#___________________________________________________

# Ensure script is run as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  Write-Warning "Please run this script as an Administrator!"
  Exit
}

# Remove UWP version of Notepad (Windows 11)
Get-AppxPackage *Microsoft.WindowsNotepad* | Remove-AppxPackage

# install
winget install -h --id="Notepad++.Notepad++"

# Path to Notepad++
$notepadPath = "${env:ProgramFiles}\Notepad++"
$notepadPlusPlus = "${notepadPath}\notepad++.exe"

# Check if Notepad++ is installed
if (-not (Test-Path $notepadPlusPlus)) {
    Write-Error "Notepad++ not found at $notepadPlusPlus. Please install Notepad++ first."
    Exit
}

# set alias
Set-Alias np $notepadPlusPlus 

$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
[Environment]::SetEnvironmentVariable("Path", $currentPath + ";" + $notepadPath, "Machine")


# Replace Notepad with Notepad++ in registry
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"
New-Item -Path $regPath -Force | Out-Null
New-ItemProperty -Path $regPath -Name "Debugger" -Value "`"$notepadPlusPlus`" -notepadStyleCmdline -z" -PropertyType String -Force | Out-Null

# Add "Edit with Notepad++" to context menu for all files
$shellKey = "HKCU:\SOFTWARE\Classes\*\shell\Notepad++"
New-Item -Path $shellKey -Force | Out-Null
Set-ItemProperty -Path $shellKey -Name "(Default)" -Value "Edit with Notepad++" -Force
New-Item -Path "$shellKey\command" -Force | Out-Null
Set-ItemProperty -Path "$shellKey\command" -Name "(Default)" -Value "`"$notepadPlusPlus`" `"%1`"" -Force

Write-Host "Notepad has been replaced with Notepad++ system-wide and added to path and aliases"

mklink C:\Windows\System32\np.exe "C:\Program Files\Notepad++\notepad++.exe"
