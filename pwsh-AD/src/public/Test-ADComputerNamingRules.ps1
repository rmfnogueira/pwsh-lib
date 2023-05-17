function Test-ADComputerNamingRules {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
        [Object[]]
        $Objects
    )
    BEGIN {
        Write-Verbose "[BEGIN]: $($MyInvocation.MyCommand)"
        Write-Verbose '[BEGIN]: Testing log file path...'
        Set-LogPath
        
        # Set regex object for name testing
        [regex]$expressao = '^((s|S){1}\d{4})'
    }
    PROCESS {
        $Computers = $Objects | Where-Object {$_.ObjectClass -eq 'computer'}
        foreach ($pc in $Computers) {
            try {
                Write-Verbose "Testing computer naming on $($pc.name)"
                if (!($pc.name -match $expressao)) {

                    Disable-ADAccount $pc.ObjectGUID
                    Write-Verbose "Disabled $pc.Name account" 
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
 } #Test-ADComputerNamingRules