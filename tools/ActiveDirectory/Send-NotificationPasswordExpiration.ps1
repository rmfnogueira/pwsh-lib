# For each user, it retrieves the password policies by making a GET request to the users/{id}/passwordPolicies endpoint, the response contains a validityPeriod object that has an endDateTime property, which represents the date and time when the user's password will expire. It then converts the endDateTime string to a datetime object, and calculates the number of days until the password expires.
# If the number of days until the password expires is less than or equal to the expirationThreshold constant, the script sends a notification to the user by making a POST request to the users/{id}/sendMail endpoint, passing the appropriate message in the request body.

# Constants
$clientId
$clientSecret
$tenantId
$expirationThreshold = 15

# Get Access Token
try {
    $tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $body = @{
        client_id     = $clientId
        scope         = 'https://graph.microsoft.com/.default'
        client_secret = $clientSecret
        grant_type    = 'client_credentials'
    }
    $tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ErrorAction Stop
    $accessToken = $tokenResponse.access_token
}
catch {
    Write-Error "Error getting access token: $_"
    return
}

# Configure headers
$headers = @{
    'Authorization' = "Bearer $accessToken"
    'Content-Type'  = 'application/json'
}


# Get all users 

try {
    $usersEndpoint = "https://graph.microsoft.com/v1.0/users?$count=true&$filter=proxyAddresses/any (p:endsWith(p, 'Contoso.com'))&$select=id,displayName,proxyaddresses,mail"
    $usersResponse = Invoke-RestMethod -Method Get -Uri $usersEndpoint -Headers $headers -ErrorAction Stop
    $users = $usersResponse.value
}
catch {
    Write-Error "Error getting users: $_"
    return
}

# Check password expiration for each user
foreach ($user in $users) {
    try {
        $passwordPoliciesEndpoint = "https://graph.microsoft.com/v1.0/users/$($user.id)/passwordPolicies"
        $passwordPoliciesResponse = Invoke-RestMethod -Method Get -Uri $passwordPoliciesEndpoint -Headers $headers -ErrorAction Stop
        $passwordExpirationDate = [datetime]::parse($passwordPoliciesResponse.validityPeriod.endDateTime)
        $daysUntilExpiration = ($passwordExpirationDate - (Get-Date)).days
        if ($daysUntilExpiration -le $expirationThreshold) {
            try {
                $email = $user.mail
                $message = @{
                    subject      = 'Password Expiration Notification'
                    toRecipients = @(@{emailAddress = @{address = user@contoso.com } })
                    body         = @{content = "Your password will expire in $daysUntilExpiration days, please change it." }
                } | ConvertTo-Json
                $notificationEndpoint = "https://graph.microsoft.com/v1.0/users/$($user.id)/sendMail"
                Invoke-RestMethod -Method Post -Uri $notificationEndpoint -Headers $headers -Body $message -ErrorAction Stop
            }
            catch {
                Write-Error "Error sending notification to user $($user.userPrincipalName): $_"
            }
        }
    }
    catch {
        Write-Error "Error getting password policies for user $($user.userPrincipalName): $_"
    }
}