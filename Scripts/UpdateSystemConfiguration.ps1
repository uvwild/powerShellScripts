function Update-SystemConfiguration {
    param (
        [string]$OutputFile = "system_configuration.json",
        [string]$GitRepositoryPath = "C:\Users\uv\OneDrive\PowerShell"
    )

    # Ensure the script is running in PS7
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Error "This script requires PowerShell 7 or higher."
        return
    }

    # Collect installed software
    $installedSoftware = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", `
                                          "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
                        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
                        Where-Object { $null -ne $_.DisplayName }

    # Collect hardware information
    $hardwareInfo = Get-CimInstance -ClassName Win32_ComputerSystem, Win32_Processor, Win32_PhysicalMemory, Win32_DiskDrive |
                    Select-Object __Class, *

    # Collect installed PS modules
    $psModules = Get-InstalledModule | Select-Object Name, Version, Repository

    # Collect Python packages
    $pythonPackages = & python -m pip list | Out-String

    # Collect winget output
    $wingetOutput = winget list | Out-String

    # Convert to JSON (full object)
    $systemConfiguration = [PSCustomObject]@{
        Timestamp           = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        InstalledSoftware   = $installedSoftware
        HardwareInformation = $hardwareInfo
        PSModules           = $psModules
        PythonPackages      = $pythonPackages
        WingetList          = $wingetOutput
    }
    $jsonOutput = $systemConfiguration | ConvertTo-Json -Depth 3 -Compress

    # Write JSON to file
    $outputFilePath = Join-Path -Path $GitRepositoryPath -ChildPath $OutputFile
    Set-Content -Path $outputFilePath -Value $jsonOutput -Encoding UTF8

    # Create the .myconfig folder if needed
    $myConfigFolder = Join-Path -Path $GitRepositoryPath -ChildPath ".myconfig"
    if (-not (Test-Path $myConfigFolder)) {
        New-Item -ItemType Directory -Path $myConfigFolder | Out-Null
    }

    # Place each configuration part in a separate file at depth 5
    $configItems = @{
        installedsoftware = $installedSoftware
        hardwareinfo      = $hardwareInfo
        psmodules         = $psModules
        pythonpackages    = $pythonPackages
        winget            = $wingetOutput
    }
    $maxDepth = 5
    foreach ($item in $configItems.GetEnumerator()) {
        $jsonChunk = $item.Value | ConvertTo-Json -Depth $maxDepth -Compress
        if ($jsonChunk -like "*...*") {
            Write-Warning "Data for '$($item.Key)' might be truncated at depth $maxDepth. Use a higher depth if needed."
        }
        $filePath = Join-Path -Path $myConfigFolder -ChildPath ("config.{0}.json" -f $item.Key)
        Set-Content -Path $filePath -Value $jsonChunk -Encoding UTF8
    }

    # Combine all members into one YAML file (requires a module like powershell-yaml)
    $allConfig = [ordered]@{}
    foreach ($cItem in $configItems.GetEnumerator()) {
        $allConfig[$cItem.Key] = $cItem.Value
    }
    if (Get-Module -ListAvailable | Where-Object { $_.Name -eq "powershell-yaml" }) {
        Import-Module powershell-yaml -ErrorAction SilentlyContinue
        $yamlOutput = $allConfig | ConvertTo-Yaml
        if ($yamlOutput -like "*...*") {
            Write-Warning "Combined YAML might be truncated. Consider deeper serialization."
        }
        $yamlFilePath = Join-Path -Path $myConfigFolder -ChildPath "config.combined.yaml"
        Set-Content -Path $yamlFilePath -Value $yamlOutput -Encoding UTF8
    } else {
        Write-Warning "powershell-yaml is not installed, skipping YAML creation."
    }

    # If in Git repo, commit changes
    if (Test-Path (Join-Path -Path $GitRepositoryPath -ChildPath ".git")) {
        Push-Location $GitRepositoryPath
        git add $OutputFile
        git commit -m "Updated system configuration: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

        # Check Git status and commit changes if any
        git status
        $statusOutput = git status --porcelain
        if ($statusOutput) {
            $changedMembers = $statusOutput | ForEach-Object {
                if ($_ -match '^.[ARM] \s+\.myconfig\\config\.(\w+)\.json') {
                    $matches[1]
                } elseif ($_ -match '^.[ARM] \s+\.myconfig\\config\.combined\.yaml') {
                    "combined"
                }
            } | Sort-Object -Unique

            if ($changedMembers) {
                git add ".myconfig"
                git commit -m "new system configuration with changes in $($changedMembers -join ', ')"
            }
        }
        Pop-Location
    } else {
        Write-Warning "The specified path is not a Git repository. Skipping commit step."
    }

    Write-Output "System configuration updated and saved to $OutputFile and .myconfig."
}
