function Add-ConditionalGroupMember {
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
        $ConditionalGroups = @{
            <#
            Add Groups Objects ObjectID here, like so:

            ALLOW_GROUP_CREATION = 'ObjectID'
            #>
        }
    }
    PROCESS {
        foreach ($object in $objects) {
            try {
                if ($object.ObjectClass -eq 'user') {
                    if ($object.DistinguishedName -match "name_to_match") {
                        Write-Verbose "[PROCESS]:: Adding $object.SamAccountName to $($ConditionalGroups[0]) and $($ConditionalGroups[1])"
                        Add-ADGroupMember -Identity $ConditionalGroups[0] -Members $object
                        Add-ADGroupMember -Identity $ConditionalGroups[1] -Members $object
                    }
                    elseif ($object.DistinguishedName -match "name_to_match") {
                        Write-Verbose "[PROCESS]:: Adding $object.SamAccountName to $($ConditionalGroups[0]),$($ConditionalGroups[1]),$($ConditionalGroups[2])" 
                        Add-ADGroupMember -Identity  $ConditionalGroups -Members $object
                        Add-ADGroupMember -Identity  $ConditionalGroups -Members $object
                        Add-ADGroupMember -Identity  $ConditionalGroups -Members $object
                    }
                    elseif ($object.DistinguishedName -match "name_to_match") {
                        Write-Verbose "[PROCESS]:: Adding $object.SamAccountName to $($ConditionalGroups[3])" 
                        Add-ADGroupMember -Identity $ConditionalGroups[3] -Members $object
                    }
                }
                if (($object.ObjectClass -eq 'computer') -and ($object.DistinguishedName -match 'Server')) {
                    Write-Verbose "[PROCESS]:: Adding $object.SamAccountName to $($ConditionalGroups[4])"
                    Add-ADGroupMember -Identity $ConditionalGroups[4] -Members $object
                }
            }
            catch {
                throw $_ | Tee-Object -Append -FilePath "$($LogPath)\$($MyInvocation.MyCommand).txt"   
            }
        }
    } END {
        Write-Verbose "[END]: $($MyInvocation.MyCommand)"
    }
}