

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
$PSVersionTable.PSVersion
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
        [string]$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $installedPackages = winget list

    $packageList = $installedPackages | Out-String -Stream | Where-Object { $_.Trim() -ne "" }
    $packageList = $packageList | Select-Object -Skip 2

    $packageDetails = foreach ($package in $packageList) {
        $packageName = $package -split '\s{2,}' | Select-Object -First 1
        $registryEntries = Get-ItemProperty -Path $RegistryPath -ErrorAction SilentlyContinue | Where-Object {
            $_.DisplayName -eq $packageName
        }

        foreach ($entry in $registryEntries) {
            [PSCustomObject]@{
                Name             = $entry.DisplayName
                Version          = $entry.DisplayVersion
                InstallLocation  = $entry.InstallLocation
                Publisher        = $entry.Publisher
            }
        }
    }

    return $packageDetails
}
$packages = Get-WingetInstalledPackages
$packages | Format-Table -AutoSize


#Write-Output "Shortcut created on desktop: $shortcutPath" -ForegroundColor Green
