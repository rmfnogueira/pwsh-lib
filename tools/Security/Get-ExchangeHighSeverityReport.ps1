# Define the Graph Security API endpoint and version
$graphEndpoint = "https://graph.microsoft.com/beta"

# Define the application's credentials
$clientID = "<client_id>"
$clientSecret = "<client_secret>"
$tenantID = "<tenant_id>"

# Authenticate to the Graph API using OAuth
$tokenEndpoint = "https://login.microsoftonline.com/$tenantID/oauth2/token"
$body = @{
    grant_type = "client_credentials"
    client_id = $clientID
    client_secret = $clientSecret
    scope = "https://graph.microsoft.com/.default"
}
$oauthResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body
$accessToken = $oauthResponse.access_token

# Define the query for Exchange high-level warnings
$query = "securityResources | where providerId == 'Exchange' | where category == 'High'"

# Get the security report using the Graph Security API
$reportEndpoint = "$graphEndpoint/security/alerts?$query"
$headers = @{
    Authorization = "Bearer $accessToken"
    ContentType = "application/json"
}
$report = Invoke-RestMethod -Method Get -Uri $reportEndpoint -Headers $headers

# Display the security report
$report | Format-Table -AutoSize

# Confirm that the script has completed successfully
Write-Host "Exchange high-level warnings have been retrieved from the Microsoft Graph Security API."
