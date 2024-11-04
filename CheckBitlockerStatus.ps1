# Define number of cycles after which to calculate remaining time
$cyclesForEstimate = 5
$checkSeconds = 20
$loopCount = 0
$initialPercentage = $null
$timeStamps = @()

Write-Host "Starting BitLocker Status Check:" (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") -ForegroundColor Green

while ($true) {
    # Get current timestamp
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $timeStamps += Get-Date  # Store timestamp for loop duration calculations
    
    # Check the BitLocker status on the C: drive
    $status = manage-bde -status C: | Select-String "Percentage"
    
    # Display the current status with timestamp
    if ($status) {
        Write-Host "`r$timestamp - BitLocker Status: $status" -ForegroundColor Yellow -NoNewline

        # Extract the current percentage as a number
        $currentPercentage = [double]($status.ToString() -replace '[^\d,]', '') -replace ',', '.'

        # Initialize percentage tracking
        if ($null -eq $initialPercentage) { $initialPercentage = $currentPercentage }
        
        # Increment loop counter
        $loopCount++
        
        # Calculate and display expected remaining time after every defined cycle
        if ($loopCount -eq $cyclesForEstimate) {
            # Calculate average duration per loop in seconds
            $averageLoopDuration = (($timeStamps[-1] - $timeStamps[0]).TotalSeconds) / $cyclesForEstimate

            # Calculate decryption rate per loop
            $decryptionRate = ($initialPercentage - $currentPercentage) / $cyclesForEstimate
            
            # Estimate remaining loops based on decryption rate and remaining percentage
            $remainingLoops = ($currentPercentage / $decryptionRate)
            $estimatedRemainingTime = [TimeSpan]::FromSeconds($averageLoopDuration * $remainingLoops)
            
            Write-Host "`r$timestamp - Estimated remaining time: $estimatedRemainingTime" -ForegroundColor Cyan
            
            # Reset variables for the next estimation cycle
            $initialPercentage = $currentPercentage
            $loopCount = 0
            $timeStamps.Clear()
        }
    } else {
        Write-Host "$timestamp - Unable to retrieve status or encryption may be off." -ForegroundColor Red
    }
    
    # Exit the loop if encryption is fully disabled
    if ($status -and $status.ToString().Contains(" 0,0%")) {
        Write-Host "$timestamp - Encryption is fully disabled on the C: drive." -ForegroundColor Green
        break
    }

    # Wait for 30 seconds before checking again
    Start-Sleep -Seconds $checkSeconds
}
