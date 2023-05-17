# Set variables for the search
$disabledOU = "OU=Disabled Users,DC=domain,DC=com"
$daysInactive = 365

# Get all user accounts that haven't logged on in over a year
$users = Get-ADUser -Filter {LastLogonDate -lt (Get-Date).AddDays(-$daysInactive)} -Properties LastLogonDate

# Loop through each user and disable their account and move them to the Disabled OU
foreach ($user in $users) {
    Disable-ADAccount $user
    Move-ADObject $user -TargetPath $disabledOU
}

# Confirm that the script has completed successfully
Write-Host "All users who have not logged on in over a year have been disabled and moved to the Disabled Users OU."


# NOTIFY
# Make sure to update the <client_id>, <client_secret>, and <tenant_id> placeholders with the appropriate values for your Azure AD application. Also, note that this script sends the same email message to all disabled users. You may want to modify the script to include personalized information in each user's email notification.

# Define the Graph API endpoint and version
$graphEndpoint = "https://graph.microsoft.com/v1.0"

# Define the application's credentials
$clientID = "<client_id>"
$clientSecret = "<client_secret>"
$tenantID = "<tenant_id>"

# Define the user's email message
$emailSubject = "Account Disabled"
$emailBody = "Dear user, your account has been disabled due to inactivity. Please contact the IT department if you have any questions."

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

# Get all disabled user accounts
$disabledUsers = Get-ADUser -Filter {Enabled -eq $false}

# Loop through each disabled user and send them an email notification
foreach ($user in $disabledUsers) {
    $userEmail = $user.UserPrincipalName
    $emailEndpoint = "$graphEndpoint/users/$userEmail/sendMail"
    $emailBody = @{
        message = @{
            subject = $emailSubject
            body = @{
                contentType = "Text"
                content = $emailBody
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = $userEmail
                    }
                }
            )
        }
        saveToSentItems = "true"
    }
    $headers = @{
        Authorization = "Bearer $accessToken"
        ContentType = "application/json"
    }
    Invoke-RestMethod -Method Post -Uri $emailEndpoint -Headers $headers -Body ($emailBody | ConvertTo-Json)
}

# Confirm that the script has completed successfully
Write-Host "Email notifications have been sent to all users whose accounts have been disabled."
