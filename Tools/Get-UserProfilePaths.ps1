function Get-UserProfilePaths {
    [cmdletbinding()]
    <#
    .SYNOPSIS
    Gets current logged on user profile paths (environment).
    .EXAMPLE
    Get-CurrentUserPaths
    Outputs all current paths
    #>    
    param 
    (
        #Intentionally left empty
    )
        Write-Verbose "[BEGIN   ] Starting $($MyInvocation.MyCommand)"
        $enumPaths = [enum]::GetNames([System.Environment+SpecialFolder])
    foreach ($enum in $enumPaths) 
        {
            $paths=([environment]::GetFolderPath($enum))
            [pscustomobject]@{
                'Name' = "$enum"
                'Path' = "$paths"        
            }
        } #foreach
        Write-Verbose "[END ] Ending $($MyInvocation.MyCommand)"
} #Get-LocalUserFolderPath