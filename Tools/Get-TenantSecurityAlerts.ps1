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

# Define the query for security alerts
$query = ""

# Get the security alerts using the Graph Security API
$alertsEndpoint = "$graphEndpoint/security/alerts?$query"
$headers = @{
    Authorization = "Bearer $accessToken"
    ContentType = "application/json"
}
$alerts = Invoke-RestMethod -Method Get -Uri $alertsEndpoint -Headers $headers

# Display the security alerts
$alerts | Format-Table -AutoSize

# Confirm that the script has completed successfully
Write-Host "Security alerts have been retrieved from the Microsoft Graph Security API."
