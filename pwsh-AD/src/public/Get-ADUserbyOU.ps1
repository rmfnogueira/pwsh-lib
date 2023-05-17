function Get-ADUserbyOU {
    [cmdletbinding()]

    param (
        [parameter(
            ValueFromPipeline,
            ValueFromPipelinebyPropertyName)]
        [ValidateNotNullorEmpty()]
        [string[]]$Searchbase
    )
    begin {
        Write-Verbose "[begin]  Starting $($MyInvocation.MyCommand)"

        $selected_properties =
        'CN',
        'DistinguishedName',
        'EmployeeType',
        'Enabled',
        'GivenName',
        'Mail',
        'Name',
        'ObjectClass',
        'ObjectGUID',
        'SamAccountName',
        'SID',
        'Surname',
        'UserPrincipalName',
        'WhenChanged',
        'WhenCreated'

        $params = @{
            'Filter'     = '*'
            'Properties' = $selected_properties
        }
    }
    process {
        foreach ($ou in $searchbase) {
            Write-Verbose "[process:    Getting user data from $ou]"
            Get-ADUser @params -SearchBase $ou
        }
    }
    end { Write-Verbose "[end]:  ending $($MyInvocation.MyCommand)" } 
}