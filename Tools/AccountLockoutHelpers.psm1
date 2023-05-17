function FunctionName {
    [cmdletbinding()]
    param (
        [help("Please enter a username or an array of usernames to lookup")]
        [string[]]$Username
    )
    BEGIN{
        $PDC = Get-ADDomainController -Discover -Service PrimaryDC.Name
        $DCs = Get-ADDomainController -Filter * | 
        Select-Object name,IpAddress
    }
    PROCESS{
        foreach ($user in $users) {
            foreach ($DC in $DCs) {
                if ($DC -eq $PDC) {
                    Write-Verbose -ForegroundColor Green "$DC is the PDC"
                }
                Get-WinEvent -ComputerName $DC -Logname Security -FilterXPath "*[System[EventID=4740 or EventID=4625 or EventID=4770 or EventID=4771 and TimeCreated[timediff(@SystemTime) <= 3600000]] and EventData[Data[@Name='TargetUserName']='$user']]" | 
                Select-Object TimeCreated,@{Name='User Name';Expression={$_.Properties[0].Value}},@{Name='Source Host';Expression={$_.Properties[1].Value}} -ErrorAction SilentlyContinue
            }
        }
    }
    END{}
}




