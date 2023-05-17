function Get-OneDriveInfo {
    [CmdletBinding()]
    param (
        [Parameter()]
        [TypeName]
        $UserPrincipalName
    )
    $url = "https://graph.microsoft.com/v1.0/users/$($UserPrincipalName)/drive"
    Invoke-RestMethod -UseBasicParsing -Headers ([ConnectionHandler]::connect()) -Uri $url -Method Get -Verbose
} #GetOneDriveInfo
    

