function Add-ConditionalGroupMember {
    <#
    Adiciona um objecto, criado num periodo de tempo, a um grupo active directory, perante condição predefenida.
    O match para adicao é feito pelo DistinguishedName,dado que todos os objetos devem estar na localização correta na AD (ou alternativamente membro de grupo especifico)
    #>
        [CmdletBinding()]
        param (
            [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
            [Object[]]
            $Objects
        )
        begin {
            Write-Verbose "[begin]: $($MyInvocation.MyCommand)"
            Write-Verbose '[begin]: Testing log file path...'
            Set-LogPath
            $ConditionalGroups = @{
            
                CRIAR_GRUPOS_TENANT = 'b874b385-2339-4353-9b2a-10f946adfee2'
    
                ALUNOS_TODOS = '6f72b085-1582-4513-9143-a985cf40a9a9'
                
                DOCENTES_TODOS = 'b464da64-b8d8-4a50-a9e4-c154762a3c1c'
                
                COLABORADORES_TODOS ='08fdf870-5b6a-4a4a-8d27-7b6d32f66a30'
                
                EDU_SERVERS = '767f2313-5708-4e62-ad31-e523fef7796d'
                
                ACESSO_VPN = '3b9c9bab-90cb-4004-9317-a8adfcdb7f96'
            }
        }
        process {
            foreach ($object in $objects) {
                try {
                    if ($object.ObjectClass -eq 'user') {
                        if ($object.DistinguishedName -match 'Docentes') {
                            Write-Verbose "[process]:: Adding $object.SamAccountName to $($ConditionalGroups.CRIAR_GRUPOS_TENANT) and $($ConditionalGroups.DOCENTES_TODOS)"
                            Add-ADGroupMember -Identity $ConditionalGroups.CRIAR_GRUPOS_TENANT -Members $object
                            Add-ADGroupMember -Identity $ConditionalGroups.DOCENTES_TODOS -Members $object
                        }
                        elseif ($object.DistinguishedName -match 'Colaboradores') {
                            Write-Verbose "[process]:: Adding $object.SamAccountName to $($ConditionalGroups.CRIAR_GRUPOS_TENANT),$($ConditionalGroups.COLABORADORES_TODOS),$($ConditionalGroups.ACESSO_VPN)" 
                            Add-ADGroupMember -Identity  $ConditionalGroups.CRIAR_GRUPOS_TENANT -Members $object
                            Add-ADGroupMember -Identity  $ConditionalGroups.COLABORADORES_TODOS -Members $object
                            Add-ADGroupMember -Identity  $ConditionalGroups.ACESSO_VPN -Members $object
                        }
                        elseif ($object.DistinguishedName -match 'Alunos') {
                            Write-Verbose "[process]:: Adding $object.SamAccountName to $($ConditionalGroups.ALUNOS_TODOS)" 
                            Add-ADGroupMember -Identity $ConditionalGroups.ALUNOS_TODOS -Members $object
                        }
                    }
                    if (($object.ObjectClass -eq 'computer') -and ($object.DistinguishedName -match 'Server')) {
                        Write-Verbose "[process]:: Adding $object.SamAccountName to $($ConditionalGroups.EDU_SERVERS)"
                        Add-ADGroupMember -Identity $ConditionalGroups.EDU_SERVERS -Members $object
                    }
                }
                catch {
                    throw $_ | Tee-Object -Append -FilePath "$($LogPath)\$($MyInvocation.MyCommand).txt"   
                }
            }
        } end {
            Write-Verbose "[end]: $($MyInvocation.MyCommand)"
        }
    }#Add-ConditionalGroupMember