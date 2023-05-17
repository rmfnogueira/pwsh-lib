function Invoke-Build {
    [CmdLetBinding()]
    param ([string]$module)

    BEGIN {
        Push-Location $PSScriptRoot
    }
    PROCESS {
        dotnet build $PSScriptRoot\src -o $PSScriptRoot\output\$module\bin
        Copy-Item "$PSScriptRoot\$module\*" "$PSScriptRoot\output\$module" -Recurse -Force
        Import-Module "$PSScriptRoot\Output\$module\$module.psd1"
        Invoke-Pester "$PSScriptRoot\Tests"
    }
    END {}
}