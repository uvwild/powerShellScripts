# EnableNetworkDiscovery
function EnableNetworkDiscovery () {

    Write-Output "Enabling NetworkDiscovery..."
    Set-NetFirewallRule -DisplayGroup "Network Discovery" -Enabled True
    Try { Start-Service -Name "FDResPub" } Catch { Write-Output "Error starting FDResPub: $_" }
    Try { Start-Service -Name "SSDPSRV" } Catch { Write-Output "Error starting SSDPSRV: $_" }
    Try { Start-Service -Name "upnphost" } Catch { Write-Output "Error starting upnphost: $_" }



    # Enable File and Printer Sharing
    Write-Output "Enabling File and Printer Sharing..."
    Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Enabled True

    # Set Network Profile to Private (File sharing is typically enabled on private networks)
    Write-Output "Setting network profile to Private..."
    $networkProfile = Get-NetConnectionProfile
    Set-NetConnectionProfile -InterfaceIndex $networkProfile.InterfaceIndex -NetworkCategory Private

    # Confirm settings
    Write-Output "Network Discovery and File Sharing are now enabled."
}

$EnableNetworkDiscovery = Read-Host "Do you want to EnableNetworkDiscovery ? (Y/N)"
if ($EnableNetworkDiscovery -match '^[Yy]$') {
    EnableNetworkDiscovery
}
