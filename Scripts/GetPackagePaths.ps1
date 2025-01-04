

function GetPackagePath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    function Get-ExecutableFromPath {
        param (
            [string]$Path
        )

        if (-not (Test-Path $Path)) {
            return $null
        }

        $executableFiles = Get-ChildItem -Path $Path -File | Where-Object {
            $_.Extension -in @('.exe', '.cmd', '.bat', '.ps1') -and $_.Name -notmatch '(?i)uninstall'
        }

        return $executableFiles.FullName | Select-Object -First 1
    }

    function SafeGetRegistryProperty {
        param (
            [string]$PSPath,
            [string]$PropertyName
        )

        try {
            return (Get-ItemProperty -Path $PSPath -ErrorAction Stop).$PropertyName
        } catch {
            Write-Verbose "Property '$PropertyName' not found in registry path: $PSPath"
            return $null
        }
    }

    # Step 1: Check Winget Links
    Write-Verbose "Checking WinGet Links..."
    $wingetLinks = "C:\Users\$env:USERNAME\AppData\Local\Microsoft\WinGet\Links"
    $linkPath = Get-ChildItem -Path $wingetLinks -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -like "*$PackageName*"
    } | ForEach-Object {
        Get-ItemTarget $_.FullName
    }

    $executable = Get-ExecutableFromPath -Path $linkPath
    if ($executable) {
        Write-Verbose "Found executable path in WinGet Links: $executable"
        return $executable
    }

    # Step 2: Check Registry (64-bit)
    Write-Verbose "Checking 64-bit registry..."
    $registryPath64 = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue | Where-Object {
        SafeGetRegistryProperty -PSPath $_.PSPath -PropertyName "DisplayName" -like "*$PackageName*"
    } | ForEach-Object {
        SafeGetRegistryProperty -PSPath $_.PSPath -PropertyName "InstallLocation"
    }

    $executable = Get-ExecutableFromPath -Path $registryPath64
    if ($executable) {
        Write-Verbose "Found executable path in 64-bit registry: $executable"
        return $executable
    }

    # Step 3: Check Registry (32-bit)
    Write-Verbose "Checking 32-bit registry..."
    $registryPath32 = Get-ChildItem -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue | Where-Object {
        SafeGetRegistryProperty -PSPath $_.PSPath -PropertyName "DisplayName" -like "*$PackageName*"
    } | ForEach-Object {
        SafeGetRegistryProperty -PSPath $_.PSPath -PropertyName "InstallLocation"
    }

    $executable = Get-ExecutableFromPath -Path $registryPath32
    if ($executable) {
        Write-Verbose "Found executable path in 32-bit registry: $executable"
        return $executable
    }

    # Step 4: Check PATH environment variable
    Write-Verbose "Checking PATH environment variable..."
    $pathEntry = $env:PATH -split ';' | Where-Object {
        $_ -like "*$PackageName*"
    }

    $executable = Get-ExecutableFromPath -Path $pathEntry
    if ($executable) {
        Write-Verbose "Found executable path in PATH environment variable: $executable"
        return $executable
    }

    # Step 5: File System Search
    Write-Verbose "Searching Start Menu Programs..."
    $programMenuPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    $fileSystemPath = Get-ChildItem -Recurse -Path $programMenuPath -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -like "*$PackageName*"
    } | Select-Object -First 1 -ExpandProperty FullName

    $executable = Get-ExecutableFromPath -Path $fileSystemPath
    if ($executable) {
        Write-Verbose "Found executable path in file system: $executable"
        return $executable
    }

    Write-Verbose "No executable path found for package: $PackageName"
    return $null
}
