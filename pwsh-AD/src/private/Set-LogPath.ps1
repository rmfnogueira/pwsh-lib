function Set-LogPath {
    [CmdletBinding()]
    param (
        # LogPath defined on module scope
        [Parameter()]
        [string]
        $Path = $LogPath
    )
    try {
        if (!(Test-Path -Path $Path)) {
            Write-Host '[Creating Log Path]' 
            [System.IO.Directory]::CreateDirectory($Path)
        }
    }
    catch {
        throw "Could not create target directory, please check your system configuration"
        break
    }
}