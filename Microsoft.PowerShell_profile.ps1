# C:\Users\uv\OneDrive\OneDriveDocuments\PowerShell\Microsoft.PowerShell_profile.ps1
#echo "we have been used"
function Show-Env {
    Get-ChildItem Env:
}
Set-Alias env Show-Env
function Show-Path { Get-ChildItem Env:Path }
Set-Alias path Show-Path

#echo "we are done here"

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
