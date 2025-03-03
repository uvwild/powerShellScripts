$RouterIP = "router"   # "192.168.66.1"
$Username = "root"  # Replace with actual username
#$Password = "XXXXXXXX"  # we are using ssh key mynetwork
$SshKey = "mynetwork"
# Check if the file exists
$SshKeyPath = "$HOME/.ssh/$SshKey"
if (Test-Path -Path $SshKeyPath) {
    Write-Host "Using: $filePath"
} else {
    Write-Host "No SShKey found in $SshKeyPath"
}

function myssh {
    param (
        [string]$Command
    )
    Write-Host "Sending $Command to $RouterIP" -ForegroundColor Cyan
    $sshCommand = "ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$RouterIP $Command"
    Write-Host "Executing: $sshCommand"
    Invoke-Expression $sshCommand
}
# SSH command to retrieve DHCP leases and ARP table
$DhcpCommand = "cat /tmp/dhcp.leases"
$ArpCommand = "cat /proc/net/arp"

# Execute SSH command
$SSHResult =  myssh $DhcpCommand

# Process and output results
Write-Host "Connected Devices: $SSHResult" -ForegroundColor Cyan
$SSHResult -split "`n" | ForEach-Object { $_ }

exit
# Parse the response content to extract device information
# Note: This parsing logic may need to be adjusted based on the actual HTML structure of the page
$DeviceInfoPattern = '<tr><td>(?<Hostname>.*?)</td><td>(?<MACAddress>.*?)</td><td>(?<IPAddress>.*?)</td></tr>'
$DeviceMatches = [regex]::Matches($Response.Content, $DeviceInfoPattern)

# Filter for Android devices and display their IP addresses
$AndroidDevices = $DeviceMatches | Where-Object { $_.Groups["Hostname"].Value -like "*android*" }
$AndroidIPs = $AndroidDevices | ForEach-Object { $_.Groups["IPAddress"].Value }

# Output the IP addresses of Android devices
$AndroidIPs
