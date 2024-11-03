#Check Teracopy

function Check-TeraCopy {
    $teracopyPath = "${env:ProgramFiles}\TeraCopy\TeraCopy.exe"
    
    if (Test-Path $teracopyPath) {
        Write-Host "TeraCopy is installed." -ForegroundColor Green
        # Write-Host "To configure TeraCopy preferences:" -ForegroundColor Yellow
        # Write-Host "1. Open TeraCopy" -ForegroundColor Yellow
        # Write-Host "2. Right-click on the interface" -ForegroundColor Yellow
        # Write-Host "3. Select 'Preferences'" -ForegroundColor Yellow
        # Write-Host "4. Enable the following options:" -ForegroundColor Yellow
        # Write-Host "   - 'Use TeraCopy as default copy handler'" -ForegroundColor Yellow
        # Write-Host "   - 'Confirm drag and drop' (optional)" -ForegroundColor Yellow
        # Write-Host "5. Click 'OK' to save the settings" -ForegroundColor Yellow
        
        # $response = Read-Host "Would you like to open TeraCopy now? (Y/N)"
        # if ($response -eq 'Y' -or $response -eq 'y') {
            # Start-Process $teracopyPath
        # }
    } else {
        Write-Host "TeraCopy is not installed at the expected location." -ForegroundColor Red
        Write-Host "Please install TeraCopy and run this script again." -ForegroundColor Yellow
    }
}

try {
	# Set the new PATH value
	Check-TeraCopy
}
catch {
	
	Write-Host "Failed to Check-TeraCopy  " -ForegroundColor Red
	Write-Host "$env:Path" -ForegroundColor Blue
}
