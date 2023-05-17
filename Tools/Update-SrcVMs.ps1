function Update-SrcVMs {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName = @(
        
        ),
        $LocalPath,
        $defaultModulePath = 'C:\Program Files\WindowsPowerShell\Modules\'
    )
    begin {}
    process {
        New-PSSession -ComputerName $ComputerName |
        ForEach-Object {
            Copy-Item -Force -Recurse -Path $LocalPath -ToSession $_ -Destination $defaultModulePath -Confirm
        }
    }
    end {}
}#Update-SrcVMs