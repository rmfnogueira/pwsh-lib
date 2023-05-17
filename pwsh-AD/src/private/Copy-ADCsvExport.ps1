function Copy-AdCsvExport {
    [CmdletBinding()]
    param (
        $computername
    )
    begin {
        Write-Verbose "[BEGIN] Starting $($MyInvocation.MyCommand)"
        $session = New-PSSession -ComputerName $computername
        $destination
        $path = Get-LatestItem
    }
    process {
        Write-Verbose "[PROCESS] Copying items to $($computername)"
        $params = @{
            'Path'        = $path.fullname 
            'ToSession'   = $session
            'Destination' = $destination
        }
        Copy-Item @params   
    }
    end {
        Write-Verbose "[END] Ending $($MyInvocation.MyCommand)"
    }
}