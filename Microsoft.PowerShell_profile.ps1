# C:\Users\uv\OneDrive\PowerShell\Microsoft.PowerShell_profile.ps1
#echo "we have been used"

$modules = @(
  "PSReadLine",
  "posh-git",
  "oh-my-posh"
)

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
function Show-Env { Get-ChildItem Env: }
function Show-Path { $env:PATH -split ';' }

# the aliases
Set-Alias env Show-Env
Set-Alias ls Get-ChildItem
Set-Alias cat Get-Content

Set-Alias path Show-Path
Set-Alias np notepad++.exe

Set-Alias reboot Restart-Computer


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
# install usefule modules

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
Write-Host "UV Profile loaded"