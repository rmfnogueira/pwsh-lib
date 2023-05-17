function Enable-TLS12 {
    [cmdletbinding()]
    param (
        [parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $ComputerName
    )
    PROCESS {
        foreach ($computer in $ComputerName) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
    }
    END{}
}
