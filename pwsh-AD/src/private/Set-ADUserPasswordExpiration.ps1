<#
.SYNOPSIS
    This command reset's the password expired status of an ActiveDirectory User Account.
.DESCRIPTION
    'pwdLastSet' Attribute is used to calculate the password age.
    The value is protected, and the only value you can set there is 0 or -1.
    -----------------------------------------------------------------------------------------------------------------------------
    If set to -1 => System will put the pwdLastSet to the current date/time. 

    Thus the 90 days, or any defined time period, will start again from the today.
    -----------------------------------------------------------------------------------------------------------------------------
    If set to 0 =>  System will expire the password right now.
    -----------------------------------------------------------------------------------------------------------------------------
.NOTES
    You set it to 0, manually or with a script, you then set it to -1 and uncheck the Never Expire option after for the account.
    This command should be run directly on domain controller, or using a session.
    Personal preference is to be run directly on DC.
.LINK
    https://serverfault.com/questions/897253/can-i-reset-the-clock-on-an-expired-password-in-ad
.EXAMPLE
    # ONE LINER Examples (Command not tested)

    # Get users to set password expiration status
    # Be carefull not to pick ALL ADUSERS

    $users = Get-ADUserbyOU -Verbose

    # Expire all passwords NOW, and set password to expire, even if it was already set
    $users | %{Set-ADUser -Identity $_.SamAccountName -Replace @{pwdLastSet = 0} -PasswordNeverExpires $false}

    # Set expiration to system policy
    $users | %{Set-ADUser -Identity $_.SamAccountName -Replace @{pwdLastSet = -1}}
#>


# Get users to set password expiration status
# Be carefull not to pick ALL ADUSERS

function Set-ADUserPasswordExpiration {
    [CmdletBinding()]
    param(
        [parameter(ParameterSetName = 'UnExpire')]
        [parameter(ValueFromPipeline, ParameterSetName = 'Expire')]
        [Microsoft.ActiveDirectory.Management.ADUser[]]
        $ADUser,

        [parameter(ParameterSetName = 'UnExpire')]
        [switch]
        $UnExpire,

        [parameter(ParameterSetName = 'Expire')]
        [switch]
        $Expire
    )
    begin {
        [Collections.ArrayList]$inputObjects = @()
        switch ($PSCmdlet.ParameterSetName) {
            'Expire' { $pwdLastSet = 0 }
            'UnExpire' { $pwdLastSet = -1 }
            '__AllParameterSets' {}
            Default {}
        }
    }
    process {
        [void]$inputObjects.Add($ADUser)
        foreach ($user in $inputObjects.SamAccountName) {
            Write-Verbose "Performing $($PSCmdlet.ParameterSetName) on user $($user.SamAccountName) password"
            Set-ADUser -Identity "$($user.SamAccountName)" -Replace @{ pwdLastSet = $pwdLastSet }
        }
    }
    end {
    }
}
    
