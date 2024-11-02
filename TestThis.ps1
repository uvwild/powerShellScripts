# scratchpad for powershell code
#$PSVersionTable.PSVersion

function Enum-Dict {
    param ([System.Collections.Generic.Dictionary[string, object]]$dict)
    foreach ($key in $dict.Keys) {
        Write-Host "Key: $key Value: $($dict[$key])"
    }
}
function Enum-Array {
    param ([array]$array)
    foreach ($item in $array) {
        Write-Host "$item"
    }
}
function Test-CommandLineOption {
    param (
        [string]$Option
    )
    Enum-Dict $PSBoundParameters
    # Check if the option is present in the command line arguments
    if ($PSBoundParameters.ContainsKey($Option)) {
        Write-Host "Option=$Option $($PSBoundParameters[$Option])   $PSBoundParameters"		
        return $true
    }
    return $false
}

foreach ($param in $PSBoundParameters.Keys) {
    Write-Host "$param : $($PSBoundParameters[$param])"
}
$shortcutPath=$env:USERPROFILE.Trim()
$argArray = $args -split ' '
Write-host $args
Enum-Array $argArray
#Test-CommandLineOption "s"

#Test-CommandLineOption "v"


function Get-WingetInstalledPackages {
    param (
        [string[]]$RegistryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        ),
        [string[]]$PortablePaths = @(
            "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\",
            "C:\Program Files\WinGet\Packages\",
            "C:\Program Files (x86)\WinGet\Packages\"
        )
    )

    $installedPackages = winget list

    $packageList = $installedPackages | Out-String -Stream | Where-Object { $_.Trim() -ne "" }
    $packageList = $packageList | Select-Object -Skip 2

    $packageDetails = foreach ($package in $packageList) {
        $packageName = $package -split '\s{2,}' | Select-Object -First 1
        $found = $false

        foreach ($path in $RegistryPaths) {
            $registryEntries = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Where-Object {
                $_.DisplayName -eq $packageName
            }

            foreach ($entry in $registryEntries) {
                [PSCustomObject]@{
                    Name             = $entry.DisplayName
                    Version          = $entry.DisplayVersion
                    InstallLocation  = $entry.InstallLocation
                    Publisher        = $entry.Publisher
                }
                $found = $true
            }

            if ($found) { break }
        }

        if (-not $found) {
            foreach ($portablePath in $PortablePaths) {
                $portableAppPath = Join-Path -Path $portablePath -ChildPath $packageName
                if (Test-Path $portableAppPath) {
                    [PSCustomObject]@{
                        Name             = $packageName
                        Version          = "Unknown"
                        InstallLocation  = $portableAppPath
                        Publisher        = "Unknown"
                    }
                    $found = $true
                    break
                }
            }
        }

        if (-not $found) {
            [PSCustomObject]@{
                Name             = $packageName
                Version          = "Unknown"
                InstallLocation  = "Not Found"
                Publisher        = "Unknown"
            }
        }
    }

    return $packageDetails
}

$packages = Get-WingetInstalledPackages
$packages | Format-Table -AutoSize


#Write-Output "Shortcut created on desktop: $shortcutPath" -ForegroundColor Green
