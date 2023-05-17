function Enable-TLS12 {
    #Registry keys and modification as per Microsoft Article
    #Added only functionality to allow parsing list of computers
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
    END{}
}
