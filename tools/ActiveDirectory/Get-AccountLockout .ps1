function Get-AccountLockout {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,HelpMessage="Enter one or more computer names separated by commas.")]
        [String[]]
        $UserName
    )
    BEGIN{
        $DCs = Get-ADDomainController -Filter * | Select-Object name,IPv4Address
    }
    PROCESS{
        foreach ($user in $users) {
            foreach ($DC in $DCs) {
                Get-WinEvent -ComputerName $DC -Logname Security -FilterXPath "*[System[EventID=4740 or EventID=4625 or EventID=4770 or EventID=4771 and TimeCreated[timediff(@SystemTime) <= 3600000]] and EventData[Data[@Name='TargetUserName']='$user']]" | Select-Object TimeCreated,@{Name='User Name';Expression={$_.Properties[0].Value}},@{Name='Source Host';Expression={$_.Properties[1].Value}} -ErrorAction SilentlyContinue
            }
        }
    }
    END{}
}