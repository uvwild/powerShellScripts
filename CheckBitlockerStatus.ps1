while ($true) {
    # Get current timestamp
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    
    # Check the BitLocker status on the C: drive
    $status = manage-bde -status C: | Select-String "Percentage"

    # Display the current status with timestamp
    if ($status) {
        Write-Host "$timestamp - BitLocker Status: $status" -ForegroundColor Yellow
    } else {
        Write-Host "$timestamp - Unable to retrieve status or encryption may be off." -ForegroundColor Red
    }
    
    # Exit the loop if encryption is fully disabled
    if ($status -and $status.ToString().Contains("00,0%")) {
        Write-Host "$timestamp - Encryption is fully disabled on the C: drive." -ForegroundColor Green
        break
    }

    # Wait for 30 seconds before checking again
    Start-Sleep -Seconds 30
}
