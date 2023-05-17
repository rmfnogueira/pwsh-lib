function Get-SPOInfo {
    # Using Search method to lookup site info
    [CmdletBinding()]
    param (
      [Parameter()]
        [string]
        $SiteName = "dadosedu"
    )
    $headers = [ConnectionHandler]::connect()
    $url = "https://graph.microsoft.com/v1.0/sites/eduazoresgov.sharepoint.com:/sites/$sitename"
  
    Invoke-RestMethod -UseBasicParsing -Headers $headers -Uri $url -Method Get -Verbose
  } # Get-SPOInfo