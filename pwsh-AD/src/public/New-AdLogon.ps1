function New-ADLogon {
<#
.SYNOPSIS
 New-ADLogon: Generates SamAccountName, UserPrincipalName, EmailAddress, Title, DisplayName, Name, GivenName, Surname, Initials, NIF, and Office values from an input object array
    
 New-ADLogon [-InputObject] <Object[]> [[-DomainFQDN] <String>]
.INPUTS 
- InputObject     : Array of objects to process
- DomainFQDN      : (Optional) The FQDN of the domain to use as the email address domain. Default is 'edu.azores.gov.local'

.OUTPUTS
- SamAccountName   : The SamAccountName of the object.
- UserPrincipalName: The UserPrincipalName of the object.
- EmailAddress     : The email address of the object.
- Title            : The title of the object.
- DisplayName      : The display name of the object.
- Name             : The name of the object.
- GivenName        : The given name of the object.
- Surname          : The surname of the object.
- Initials         : The initials of the object.
- NIF              : The NIF of the object.
- Office           : The office of the object.

.NOTES
- The function performs operations on the input object, including string operations and formatting, to create the outputs.
- The function includes verbose logging to aid in debugging and understanding the operations performed.
- The function calls an external function 'Edit-AllPunctuation' for further processing.
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Object[]]$InputObject,
        [string]$DomainFQDN = 'edu.azores.gov.pt'
    )
    begin {
        Write-Verbose "[begin]:    Starting $($MyInvocation.MyCommand)"
    }
    process {
        foreach ($obj in $InputObject) {
            Write-Verbose '[process]:   Starting String Operations. Creating GivenName,Surname,MiddleNames,Initials.)'            
            $firstandLastName = $obj.Nome.ForEach( { $tempSplit = $_ -split ' '
                    [PSCustomObject]@{
                        InputObject = $_
                        GivenName   = $tempSplit[0]
                        Surname     = $tempSplit | Select-Object -Last 1
                        MiddleNames = $tempSplit[1..($tempsplit.Length - 2)]
                        Iniciais    = $tempsplit.Substring(0, [Math]::Min($tempsplit.Length, 1))
                    }
                })
            Write-Verbose '[process]:   Configuring Initials to Upper Case.'
            $FirstInitial = $FirstAndLastName.GivenName.ToUpperInvariant().Substring(0, 1)
            $LastInitial = $firstandLastName.Surname.ToUpperInvariant().SubString(0, 1)
            $IniciaisMeio = $firstandLastName.Iniciais.Trim().ToUpperInvariant()[1..($tempsplit.Length - 2)] -join ''

            Write-Verbose '[process]:   Performing string operations. Standardizing formats'
            $GivenName = "$([System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($FirstAndLastName.GivenName))"
            $SurName = "$([System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($FirstAndLastName.Surname))"
            $DisplayName = "$($firstandLastName.Givenname)" + ' ' + "$($IniciaisMeio)" + ' ' + "$($firstandLastName.Surname)"
            $DisplayName = "$([System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($DisplayName))"
            $Name = "$([System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($obj.Nome))"
            $Name = $Name | Edit-AllPunctuation

            Write-Verbose '[process]:   Creating email based on DisplayName'
            $EmailAddress = $DisplayName.Replace(' ', '.') + "@$DomainFQDN"
            $EmailAddress = $EmailAddress | Edit-AllPunctuation
            # $Office = $Obj.'Escritorio'
            $NIF = $obj.NIF
            
            Write-Verbose '[process]:   Creating SamAccountName.'
            $BirthDSam = Get-Date -Date $obj.'Data Nascimento' -UFormat '%d%m%y'
            $SamAccountName = "$FirstInitial$LastInitial$BirthDSam"
            $UserPrincipalName = "$SamAccountName@$DomainFQDN"
               
            [PSCustomObject]@{
                'SamAccountName'        = $SamAccountName
                'UserPrincipalName'     = $UserPrincipalName
                'EmailAddress'          = $EmailAddress
                'Title'                 = $Obj.Title
                'DisplayName'           = $DisplayName
                'Name'                  = $Name
                'GivenName'             = $GivenName
                'Surname'               = $SurName
                'Initials'              = $FirstInitial + $LastInitial
                'EmployeeType'          = $NIF
                'ExtensionAttribute1'   = $NIF
                'NIF'                   = $NIF
                'Office'            = $($Obj.Escritorio)
            }
        }
    }
    end {
        Write-Verbose "[end]:   ending $($MyInvocation.MyCommand)"
    }
} #New-ADLOGON