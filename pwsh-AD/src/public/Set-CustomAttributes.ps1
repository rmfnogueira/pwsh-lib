function Set-CustomAttributes {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
        [Object[]]
        $Objects,

        [String]
        $Attribute,

        [String]
        $AttributeValue
    )
    BEGIN {
        Write-Verbose "[BEGIN]  $($MyInvocation.MyCommand)"
        Write-Verbose '[BEGIN]  Testing log file path'
        Set-LogPath
    }
    PROCESS {
        $Users = $Objects | Where-Object { $_.ObjectClass -eq 'user' }
        foreach ($user in $Users) {
            try {
                if (($user.DistinguishedName -match 'name-to-check') -or ($user.DistinguishedName -match 'name-to-check')) {
                    Write-Verbose "[PROCESS] Setting $AttributeValue on $user.SamAccountName" 
                    Set-ADUser $user.SamAccountName -Replace @{"$($Attribute)" = "$($AttributeValue)" }
                }
            }
            catch {
                throw $_ | Tee-Object -Append -FilePath "$($LogPath)\$($MyInvocation.MyCommand).txt"
            }
        }
    } 
    END {
        Write-Verbose "[END]: $($MyInvocation.MyCommand)"
    }
}