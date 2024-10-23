#setup bash mode
winget install -h JanDeDobbeleer.OhMyPosh
oh-my-posh init pwsh | Invoke-Expression
Install-Module -Name PSReadLine -Force
Install-Module -Name PSFzf -Force

# Function to convert Bash alias to PowerShell Set-Alias command
function ConvertTo-PowerShellAlias {
    param([string]$bashAlias)
    
    if ($bashAlias -match "^alias\s+(\w+)='(.+)'$") {
        $name = $matches[1]
        $value = $matches[2]
        return "Set-Alias -Name $name -Value '$value'"
    }
    return $null
}

# Path to your Bash .alias file
$bashAliasPath = "$env:HOMEPATH\.alias"

# Read the Bash .alias file and convert aliases
$psAliases = Get-Content $bashAliasPath | ForEach-Object {
    $psAlias = ConvertTo-PowerShellAlias $_
    if ($psAlias) { $psAlias }
}

# Execute the converted aliases
$psAliases | ForEach-Object {
    Invoke-Expression $_
}

# Optionally, save the converted aliases to your PowerShell profile
$psAliases | Out-File -Append $PROFILE
