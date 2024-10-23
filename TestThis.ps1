

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

Write-Output "Shortcut created on desktop: $shortcutPath" -ForegroundColor Green