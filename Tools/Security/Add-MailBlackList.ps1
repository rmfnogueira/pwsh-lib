Import-Module ExchangeOnline

$Credential = Get-Credential
Connect-ExchangeOnline -UserPrincipalName '' -Credential $UserCredential

# Define the client ID and secret for authentication with the Microsoft Graph API
$ClientId = "your-app-id"
$ClientSecret = "your-app-secret"

# Get an access token for the Microsoft Graph API
$AuthResult = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/common/oauth2/v2.0/token" -Body @{
  client_id = $ClientId
  scope = "https://graph.microsoft.com/.default"
  client_secret = $ClientSecret
  grant_type = "client_credentials"
}

# Get USER reported email domains
$Domains = @()
$NextLink = "https://graph.microsoft.com/v1.0/security/reports/spam/email/distributionGroups"

do {
  $Result = Invoke-RestMethod -Method Get -Uri $NextLink -Headers @{
    "Authorization" = "Bearer $($AuthResult.access_token)"
  }

  foreach ($Group in $Result.value) {
    $Domains += $Group.emailAddress.Split("@")[1]
  }

  $NextLink = $Result["@odata.nextLink"]
} while ($NextLink)

# Remove duplicates and add the domains to the Exchange blacklist
$Domains = ($Domains | Select-Object -Unique)
foreach ($Domain in $Domains) {
  Add-IPBlockListEntry -DomainOrIPAddress $Domain -IPBlockType Domain
}