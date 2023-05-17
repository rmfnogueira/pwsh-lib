function Get-ADUserbyAttribute {
    [cmdletbinding(PositionalBinding = $true)]
    param (
        [parameter(
            Mandatory
        )]
        [ValidateNotNullorEmpty()]
        [ValidateSet('EmployeeType', 'SamAccountName', 'UserPrincipalName', 'EmailAddress')]
        [Alias('At', 'Attr')]
        [string]$Attributes,

        [parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullorEmpty()]
        [Alias('V', 'Valor')]
        [string[]]$Value
    )
    begin {
        Write-Verbose "[begin   ] Starting $($MyInvocation.MyCommand)"
    }
    process {
        foreach ($val in $value) {
            $selectProperties = 'Name', 'EmployeeType', 'SamAccountName', 'UserPrincipalName', 'EmailAddress'
            $Params = @{
                'Filter'   = '"$Attribute)" -eq "$value"'
                'Property' = $selectProperties
            }
            Try {
                Get-ADUser @Params
            }
            catch {
                # ADUser Filter does not throw, why should it, but could warn, so..
                throw 'Erro: Can not find any user with the specified filter. Please try another parameter or wildcard' 
            }
        }
    }
    end {
        Write-Verbose "[end   ] ending $($MyInvocation.MyCommand)" 
    }
}#Get-ADUserbyAttribute