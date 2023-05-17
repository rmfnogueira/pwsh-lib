# This script first authenticates with Azure AD using an Azure AD app client ID, client secret, and tenant ID. It then uses the Microsoft Graph API to get the ID of the Exchange email blacklist with the given name, retrieve all spam and phishing reports for the last 7 days, and extract all domains reported in those reports. Finally, the script adds each reported domain to the Exchange email blacklist.
# Note that this script assumes that you have already created an Azure AD app with the necessary permissions to access the Microsoft Graph API, and that you have also created an Exchange email blacklist with the specified name. If you have not done so, you will need to modify the script accordingly.

# Parameters
$clientId = "YourClientId"       # Replace with your Azure AD app client ID
$clientSecret = "YourClientSecret"   # Replace with your Azure AD app client secret
$tenantId = "YourTenantId"       # Replace with your Azure AD tenant ID
$blacklistName = "YourBlacklistName" # Replace with the name of the Exchange email blacklist to modify

# Authenticate with Azure AD and get an access token
$authority = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$resource = "https://graph.microsoft.com"
$tokenEndpoint = "$authority?resource=$resource"
$body = @{
    "grant_type" = "client_credentials"
    "client_id" = $clientId
    "client_secret" = $clientSecret
    "resource" = $resource
}
$accessToken = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body | Select-Object -ExpandProperty access_token

# Get the ID of the Exchange email blacklist
$blacklistEndpoint = "https://graph.microsoft.com/v1.0/organization/configurations"
$blacklist = Invoke-RestMethod -Uri $blacklistEndpoint -Headers @{Authorization = "Bearer $accessToken"} -Method Get | 
    Where-Object {$_.name -eq "BlacklistEmailAddress"} | Select-Object -First 1
$blacklistId = $blacklist.id

# Get all spam and phishing reports
$reportsEndpoint = "https://graph.microsoft.com/v1.0/reports/getEmailActivityCounts"
$reportsParams = @{
    "period" = "7"
    "category" = "Spam,PhishMalware"
}
$reports = Invoke-RestMethod -Uri $reportsEndpoint -Headers @{Authorization = "Bearer $accessToken"} -Method Get -Body ($reportsParams | ConvertTo-Json)

# Get all domains reported in the spam and phishing reports
$domains = $reports.value | Where-Object {$_.displayName -eq "Top Reported Domains"} | 
    Select-Object -ExpandProperty data | Select-Object -ExpandProperty Name

# Add all reported domains to the Exchange email blacklist
foreach ($domain in $domains) {
    $blacklistEntry = @{
        "value" = $domain
    }
    $blacklistEntryEndpoint = "https://graph.microsoft.com/v1.0/organization/configurations/$blacklistId/settings"
    Invoke-RestMethod -Uri $blacklistEntryEndpoint -Headers @{Authorization = "Bearer $accessToken"} -Method Patch -Body ($blacklistEntry | ConvertTo-Json)
}

# Output a message indicating success
Write-Output "All domains reported in the last 7 days have been added to the '$blacklistName' Exchange email blacklist."
