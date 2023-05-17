function Get-LatestCreatedObjects {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Int]
        $Interval = -8
    )
    begin {
        $timestamp = (Get-Date).AddHours($Interval)
    }
    process {
        $select_properties = 'SamAccountName', 'WhenCreated', 'MemberOf', 'Title', 'Enabled'
        $params = @{
            Filter      = { WhenCreated -ge $timestamp }
            Properties  = $select_properties
        }
        Get-ADObject @params 
    }
    end {}
}#Get-LatestCreatedObjects 