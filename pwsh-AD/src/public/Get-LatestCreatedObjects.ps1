function Get-LatestCreatedObjects {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Int]
        $Interval = -4
    )
    BEGIN {
        $timestamp = (Get-Date).AddHours($Interval)
    }
    PROCESS {
        $select_properties = 'SamAccountName', 'WhenCreated', 'MemberOf', 'Title', 'Enabled'
        $params = @{
            Filter      = { WhenCreated -ge $timestamp }
            Properties  = $select_properties
        }
        Get-ADObject @params 
    }
    END {}
}