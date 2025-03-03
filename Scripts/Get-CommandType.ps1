param (
    [Parameter(Mandatory = $true)]
    [string]$Command
)
function Resolve-SymbolicLink {
    param (
        [string]$Path
    )

    if ([System.IO.File]::Exists($Path) -or [System.IO.Directory]::Exists($Path)) {
        $fileInfo = Get-Item -Path $Path -Force
        if ($fileInfo.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            return [System.IO.Path]::GetFullPath((Get-Item -Path $Path -Force).Target)
        }
    }
    return $Path
}

function Get-CommandType {
    param (
        [string]$Command
    )

    $commandInfo = Get-Command $Command -ErrorAction SilentlyContinue

    if ($null -ne $commandInfo) {
        switch ($commandInfo.CommandType) {
            'Alias' {
                Write-Output "The command '$Command' is an alias for '$($commandInfo.Definition)'." 
            }
            'Function' {
                Write-Output "The command '$Command' is a function defined in file '$($commandInfo.ScriptBlock.File)' at line $($commandInfo.ScriptBlock.StartPosition.StartLine)."
            }
            'Cmdlet' {
                Write-Output "The command '$Command' is a cmdlet."
            }
            'ExternalScript' {
                $resolvedPath = Resolve-SymbolicLink -Path $commandInfo.Source
                Write-Host "The command '$Command' is an external script located at '$($commandInfo.Source)'." -ForegroundColor Yellow
                Write-Host "Resolved Path: $resolvedPath" -ForegroundColor Green
            }
            'Application' {
                $resolvedPath = Resolve-SymbolicLink -Path $commandInfo.Source
                Write-Host "The command '$Command' is an application located at '$($commandInfo.Source)'." -ForegroundColor Yellow
                Write-Host "Resolved Path: $resolvedPath" -ForegroundColor Green
            }
            'Workflow' {
                Write-Output "The command '$Command' is a workflow."
            }
            default {
                Write-Output "The command '$Command' is of type '$($commandInfo.CommandType)'."
            }
        }
    } else {
        $resolvedPath = Resolve-SymbolicLink -Path $Command
        if (Test-Path $resolvedPath) {
            Write-Output "The string '$Command' is a path."
            Write-Host "Path: $resolvedPath" -ForegroundColor Yellow
        } else {
            Write-Output "The string '$Command' is not recognized as a command or path."
        }
    }
}

Get-CommandType -Command $Command