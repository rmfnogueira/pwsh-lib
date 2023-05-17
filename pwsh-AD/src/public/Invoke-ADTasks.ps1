function Invoke-ADTasks {
    [CmdLetBinding()]
    param (
        # nothing
    )
    Start-Transcript

    Get-LatestCreatedObjects | Add-ConditionalGroupMember;
    Get-LatestCreatedObjects | Test-ADComputerNamingRules;
    Get-LatestCreatedObjects | Set-CustomAttributes;
    Get-LatestCreatedObjects | Move-ADObjectOU;
    
    Stop-Transcript 
}