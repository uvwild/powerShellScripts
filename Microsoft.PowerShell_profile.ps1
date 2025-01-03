# C:\Users\uv\OneDrive\PowerShell\Microsoft.PowerShell_profile.ps1
#echo "we have been used"

$modules = @(
  "PSReadLine",
  "posh-git",
  "oh-my-posh"
)

function lnk {
    param ([string]$MyPath)
    if ($MyPath -like "*.lnk") {
        (New-Object -ComObject WScript.Shell).CreateShortcut($MyPath).TargetPath
    } else {
        (Get-Item -Path $MyPath).Target
    }
}

function grep {
    param(
        [string]$Pattern,
        [string[]]$Paths
    )
    if ($Paths) {
        Get-Content -Path $Paths | Select-String -Pattern $Pattern
    } else {
        $input | Select-String -Pattern $Pattern
    }
}

# shitty powershell cannot do proper aliases, so we need functions
function gs { git status }
function gip { git push }
# gc is builtin so we have to use gic
function gic {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$args
    )
    git commit @args
}
function ga {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$args
    )
    git add @args
}
# Wrapper function for easier use
function raa {
    param (
        [string]$ScriptToRun,
        [string[]]$ScriptArgs = @()
    )
    RunAsAdmin -ScriptToRun $ScriptToRun -ScriptArgs $ScriptArgs
}
function show-aliases {
    $al=$(Get-Alias).Count
    Write-Host "Profile reloaded. $al Aliases"
}
function reload {
    . $PROFILE
}
function which {
    param (
        [string]$Command
    )
    # Check if the command exists in the current session
    $result = Get-Command -Name $Command -ErrorAction SilentlyContinue
    if ($result) {
        $result.Source # Returns the path or source of the command
    } else {
        Write-Output "Command '$Command' not found"
    }
}
function gd { git diff }
function Show-Env { Get-ChildItem Env: }
function Show-Path { $env:PATH -split ';' }

# the aliases
Set-Alias env Show-Env
Set-Alias ls Get-ChildItem
Set-Alias cat Get-Content

Set-Alias path Show-Path
Set-Alias np notepad++.exe

Set-Alias reboot Restart-Computer

# Function to wrap VLC command
function vlc {
    param (
        [Parameter(Mandatory=$false)]
        [string[]]$Args
    )
    & "C:\Program Files\VideoLAN\VLC\vlc.exe" @Args
}

# Create an alias 'll' for listing the current folder and its children as JSON
function ListAsJson {
    Get-ChildItem -Path "." -Recurse
}

# Check if alias 'll' exists and remove it if it does
if (Test-Path Alias:ll) {
    Write-Host "Removing existing alias 'll'..." -ForegroundColor Yellow
    Remove-Item Alias:ll
}

# Set the alias
Set-Alias -Name ll -Value ListAsJson
Write-Host "New alias 'll' ListAsJson" -ForegroundColor Green

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

$DefaultInstallModuleOptions = " -Scope AllUsers -Force -Confirm:$false -ErrorAction Stop"
# install useful modules

foreach ($module in $modules) {
  # Check if the module is already installed
  if (!(Get-Module -ListAvailable -Name $module)) {
      try {
          $installCommand = "Install-Module -Name $module $DefaultInstallModuleOptions"
          Write-Output "Installing $module..."
          Invoke-Expression $installCommand
          Write-Output "$module installed successfully."
      } catch {
          Write-Output "Failed to install ${module}: $_"
      }
  } else {
      Write-Output "$module is already installed."
  }
}
show-aliases