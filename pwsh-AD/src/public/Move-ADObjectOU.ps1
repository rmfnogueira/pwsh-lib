function Move-ADObjectOU {
    [CmdLetBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
        [Object[]]
        $Objects
    )
    BEGIN {
        Write-Verbose "[BEGIN]: $($MyInvocation.MyCommand)"
        Write-Verbose '[BEGIN]: Testing log file path...'
        Set-LogPath

    }
    PROCESS {
        $Computers = $Objects | Where-Object { $_.ObjectClass -eq 'computer' }
        foreach ($pc in $Computers) {
            # TODO - match por OBJECT_GUID
            try {
                Write-Verbose "[PROCESS] Checking if there are Computer Objects to move $($pc.name)"
                switch -Regex ($pc.name) {
                        ('OU-NAME-TO-MATCH') {
                        Move-ADObject -Identity $pc.ObjectGUID -TargetPath 'OU-DESTINATION-PATH'
                        <#
                        Add all and any condition for all naming conventions needed, like OU-NAME-1 to target OU-XO, etc
                        #>
                    }
                }
            }
            catch {
                throw $_ | Tee-Object -Append -FilePath "$($LogPath)\$($MyInvocation.MyCommand).txt"
            }
        }
    } END {
        Write-Verbose "[END]: $($MyInvocation.MyCommand)"
    }
} #Move-ADObjectOU
