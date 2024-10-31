# C:\Users\uv\OneDrive\PowerShell\Microsoft.PowerShell_profile.ps1
#echo "we have been used"

$modules = @(
  "PSReadLine",
  "posh-git",
  "oh-my-posh"
)

# shitty powershell cannot do proper aliases, so we need functions
function gs { git status }
function Show-Env { Get-ChildItem Env: }
function Show-Path { Get-ChildItem Env:Path }

# the aliases
Set-Alias env Show-Env
Set-Alias grep Select-String
Set-Alias ls Get-ChildItem
Set-Alias cat Get-Content

Set-Alias path Show-Path

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
          Write-Output "Installing $module..."
          Install-Module -Name $module -Force -Confirm:$false -ErrorAction Stop
          Write-Output "$module installed successfully."
      } catch {
          Write-Output "Failed to install ${module}: $_"
      }
  } else {
      Write-Output "$module is already installed."
  }
}
Write-Host "UV Profile loaded"