# EnableNetworkDiscovery
Write-Output "Enabling Network Discovery..."
Set-NetFirewallRule -DisplayGroup "Network Discovery" -Enabled True
(Get-Service -Name "FDResPub").Start()
(Get-Service -Name "SSDPSRV").Start()
(Get-Service -Name "upnphost").Start()

# Enable File and Printer Sharing
Write-Output "Enabling File and Printer Sharing..."
Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Enabled True

# Set Network Profile to Private (File sharing is typically enabled on private networks)
Write-Output "Setting network profile to Private..."
$networkProfile = Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceIndex $networkProfile.InterfaceIndex -NetworkCategory Private

# Confirm settings
Write-Output "Network Discovery and File Sharing are now enabled."
