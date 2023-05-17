function Get-RandomStrongPassword {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $false)]
            [int]
            $Length = (Read-Host ‘Password length (1 – 128)’),
        
            [Parameter(Mandatory = $false)]
            [int]
            $NonAlphabeticChars = (Read-Host ‘The number of Non-alphabetic characters’)
        )
        try {
      
            Add-Type -AssemblyName System.Web.Security
            [System.Web.Security.Membership]::GeneratePassword($Length, $NonAlphabeticChars)
        }
        catch [System.ArgumentException] {
            # retrieve information about runtime error
            $info = [PSCustomObject]@{
                Exception = $_.Exception.Message
                Reason    = $_.CategoryInfo.Reason
                Target    = $_.CategoryInfo.TargetName
                Script    = $_.InvocationInfo.ScriptName
                Line      = $_.InvocationInfo.ScriptLineNumber
                Column    = $_.InvocationInfo.OffsetInLine
            }  
            # output information. Post-process collected info, and log info (optional)
            $info
        }
    }#Get-RandomStrongPassword