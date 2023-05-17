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
    begin {
        Write-Verbose "[begin]  $($MyInvocation.MyCommand)"
        Write-Verbose '[begin]  A testar caminho de ficheiro de logs.'
        Set-LogPath
    }
    process {
        $Users = $Objects | Where-Object {$_.ObjectClass -eq 'user'}
        foreach ($user in $Users) {
            try {
                if (($user.DistinguishedName -match ' ') -or ($user.DistinguishedName -match ' ')) {
                    Write-Verbose "[process] Setting $AttributeValue on $user.SamAccountName" 
                    Set-ADUser $user.SamAccountName -Replace @{"$($Attribute)" = "$($AttributeValue)"}
                }
             }
            catch {
                throw $_ | Tee-Object -Append -FilePath "$($LogPath)\$($MyInvocation.MyCommand).txt"
            }
        }
    } 
    end {
        Write-Verbose "[end]: $($MyInvocation.MyCommand)"
    }
} #Set-CustomAttributes