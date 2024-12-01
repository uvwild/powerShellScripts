function RunAsAdmin {
    param (
        [string]$ScriptToRun = $null,
        [string[]]$ScriptArgs = @()
    )

    # Check if the script is running with administrative privileges
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        if ($ScriptToRun) {
            Write-Host "Restarting $ScriptToRun with administrative privileges using 'runas'..." -ForegroundColor Yellow
            $Command = "powershell.exe -ExecutionPolicy Bypass -File `"$ScriptToRun`" $($ScriptArgs -join ' ')"
            Start-Process -FilePath "powershell.exe" -ArgumentList "-Command $Command" -Verb RunAs
        } else {
            Write-Host "No script specified. Exiting..." -ForegroundColor Red
        }
        exit
    }

    Write-Host "Script is running with administrative privileges." -ForegroundColor Green

    # If a script is provided, execute it
    if ($ScriptToRun) {
        Write-Host "Executing $ScriptToRun..." -ForegroundColor Cyan
        & $ScriptToRun @ScriptArgs
    } else {
        Write-Host "No script provided to execute." -ForegroundColor Yellow
    }
}

# Check if alias 'raa' exists and remove it if it does
if (Test-Path Alias:\raa) {
    Write-Host "Removing existing alias 'raa'..." -ForegroundColor Yellow
    Remove-Item Alias:\raa
}

