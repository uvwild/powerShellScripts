$RouterIP = "router"   # "192.168.66.1"
$Username = "root"  # Replace with actual username
#$Password = "XXXXXXXX"  # we are using ssh key mynetwork
$SshKey = "mynetwork"
# Check if the file exists
$SshKeyPath = "$HOME/.ssh/$SshKey"
if (Test-Path -Path $SshKeyPath) {
    Write-Output "Using: $filePath"
} else {
    Write-Output "No SShKey found in $SshKeyPath"
}

# SSH command to retrieve DHCP leases and ARP table
$Command = @"
cat /tmp/dhcp.leases
arp -n
"@

# Execute SSH command
$SSHResult =  ssh -i $SshKeyPath -o StrictHostKeyChecking=no $Username@$RouterIP $Command

# Process and output results
Write-Host "Connected Devices:" -ForegroundColor Cyan
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
