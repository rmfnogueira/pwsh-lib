function Get-ADUserfromGroupMember {
    [CmdLetBinding()]
    [alias('ggm')]
    param (
        [string]$Group
    )
    begin {
        [System.Collections.ArrayList]$members = @()
        [System.Collections.ArrayList]$resultUsers = @()
    }
    process {
        $members.Add((Get-ADGroupMember -Identity $group))
        foreach ($member in $members) {
            $select_properties = 'emailAddress', 'EmployeeType', 'Title'
            $params = @{
                'Identity'   = "$member.SamAccountName"
                'Properties' = $select_properties
            }
           $resultUsers.Add((Get-ADUser @params))
        }
        return $resultUsers
    }
    end {
    }
}#Get-ADUserfromGroupMember