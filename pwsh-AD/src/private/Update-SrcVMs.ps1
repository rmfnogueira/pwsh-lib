function Update-SrcVMs {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName = @(
            "specify server names here"
        ),
        $LocalPath,
        $defaultModulePath = 'C:\Program Files\WindowsPowerShell\Modules\'
    )
    $Sessions = New-PSSession -ComputerName $ComputerName
    ForEach ($session in $Sessions) {
        Write-Verbose "Updating source code on VM $session.ComputerName"
        Copy-Item -Force -Recurse -Path $LocalPath -ToSession $session -Destination $defaultModulePath -Exclude "$localpath\.git\*"
    }
}