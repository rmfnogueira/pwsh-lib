function SetDnsNetworkInterface (
    [string]$DNSServers,
    [string]$Searchbase) {
    $computername = (Get-ADComputer -Filter * -Searchbase $Searchbase -Verbose)

    foreach ($pc in $computername) {
        $Adapters = Get-NetAdapter
        foreach ($adapter in $Adapters) {
            Write-Host "Clearing DNS settings for $($Adapter.Name)..."
            Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ResetServerAddresses
                    
            Write-Host "Setting new DNS settings for $($Adapter.Name)..."
            Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses $DNSServers
        }
    }    






}
