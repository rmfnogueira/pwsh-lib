function Add-GroupMembertoGroupName {
    [cmdletbinding()]  
    param (
        [parameter()]
        [string]
        $GroupName,

        [parameter()]
        [string]
        $LogPath,

        
        [Parameter(AttributeValues)]
        [ParameterType]
        $AttributeValue
    )
    Write-Verbose "[BEGIN  ] Starting $($MyInvocation.MyCommand)"
    $LastHour = (Get-Date).AddHours(-1)   
    try {
        $UserParams = @{
            'Properties'    = 'SamAccountName', 'WhenCreated', 'memberOf'
            'Filter'        = { (title -ne "$($AttributeValue)") -and (whencreated -ge $LastHour) }
            'ErrorAction'   = 'Stop'
            'ErrorVariable' = 'UserError'
        }
        $CreatedLastHour = Get-ADUser @UserParams 
        $GroupParams = @{
            'Identity'      = $GroupName
            'Members'       = $CreatedLastHour
            'ErrorAction'   = 'Stop'
            'ErrorVariable' = 'GroupError'
        }            
        $GroupAddition = Add-ADGroupMember @GroupParams
        Write-Verbose "[PROCESS  ] Resultado adição dos membros: $GroupAddition"
        }
        catch
        {
            $GroupError | Out-File -FilePath "$LogPath\$($MyInvocation.Mycommand)_ErrorLOG.txt" -Append   
            $UserError | Out-File -FilePath " $LogPath\$($MyInvocation.Mycommand)_ErrorLOG.txt" -Append
        } #trycatch
    Write-Verbose "[$((Get-Date).TimeofDay.ToString())  ] Added $($CreatedLastHour.SamAccountName) to Group $GroupName"
}#Add-MemberPermitirCriacaoGrupos