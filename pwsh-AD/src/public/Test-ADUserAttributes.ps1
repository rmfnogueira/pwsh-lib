function Test-ADUserAttributes {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [psobject[]]$InputObject
    )
    begin {
        $attributes = @("Name", "UserPrincipalName", "EmailAddress", "EmployeeType", "ExtensionAttribute1")
    }
    process {
        foreach ($attribute in $attributes) {
            $value = $InputObject.$attribute  
            $user = Get-ADUser -Filter "$attribute -eq '$value'" -Properties $attribute
            if ($user) {
                write-host -ForegroundColor Red "The '$value' exists in ActiveDirectory: '$($user.Name)' : '$attribute'"

                # throws if theres even one value already in use
                # All values must be corrected before user creation
                throw
            }
            else {
                Write-Verbose "'$attribute': '$value' => OK"
            }
        }
    }
}
