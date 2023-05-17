function Get-OneDriveInfo {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $UserPrincipalName = "no-reply@edu.azores.gov.pt"
    )
    $headers = [ConnectionHandler]::connect()
    $url = "https://graph.microsoft.com/v1.0/users/$($UserPrincipalName)/drive"
    Invoke-RestMethod -UseBasicParsing -Headers $headers -Uri $url -Method Get -Verbose
  } #GetOneDriveInfo
  