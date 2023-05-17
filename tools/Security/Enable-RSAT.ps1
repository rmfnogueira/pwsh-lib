function Enable-RSAT {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName = 'localhost'
    )
    begin {}
    process {
        foreach ($computer in $ComputerName) {
            Get-WindowsCapability -Name RSAT* -Online | 
            Add-WindowsCapability -Online
        }
    }
    end {}
}