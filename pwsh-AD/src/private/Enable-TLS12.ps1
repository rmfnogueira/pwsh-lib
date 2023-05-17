function Enable-TLS12 {
    [cmdletbinding()]
    param (
        [parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $ComputerName = 'localhost'
    )
    PROCESS {
        foreach ($computer in $ComputerName) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
    }
    END {}
}
