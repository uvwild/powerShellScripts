# Get all USB devices from the registry and their SelectiveSuspendEnabled values
$usbDevices = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USB" -Recurse |
    Where-Object { $_.PSIsContainer -and $_.Name -match "VID_" } | ForEach-Object {
        $deviceNameKey = Get-ItemProperty -Path "$($_.PSPath)"
        $deviceName = $deviceNameKey.FriendlyName -or $deviceNameKey.DeviceDesc
        $deviceParametersPath = "$($_.PSPath)\Device Parameters"
        if (Test-Path $deviceParametersPath) {
            $parameters = Get-ItemProperty -Path $deviceParametersPath -ErrorAction SilentlyContinue
            [PSCustomObject]@{
                Name                   = $deviceName
                SelectiveSuspendEnabled = $parameters.SelectiveSuspendEnabled
            }
        }
    }

# Filter out null values and display the results
$usbDevices | Where-Object { $_ -ne $null } | Format-Table -AutoSize
