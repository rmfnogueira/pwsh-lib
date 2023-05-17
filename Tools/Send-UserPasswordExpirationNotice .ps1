# Parameters
$tenantId = "YourTenantId"       # Replace with your Azure AD tenant ID
$appId = "YourAppId"             # Replace with the ID of your registered Azure AD application
$appSecret = "YourAppSecret"     # Replace with the secret of your registered Azure AD application
$smtpServer = "YourSMTPServer"   # Replace with the SMTP server address of your email provider
$smtpPort = 587                  # Replace with the SMTP server port of your email provider
$smtpUsername = "YourSMTPUsername"   # Replace with the username for your email account
$smtpPassword = "YourSMTPPassword"   # Replace with the password for your email account
$fromAddress = "YourEmailAddress"   # Replace with the email address to use as the sender
$subject = "Password Expiration Reminder" # Replace with the email subject
$htmlBody = @"
<html>
<body>
<p>Dear [DisplayName],</p>
<p>Your password will expire on [PasswordExpirationDate]. Please change your password before it expires to avoid any interruption to your access.</p>
<p>Thank you,</p>
<p>The IT Team</p>
</body>
</html>
"@

# Authenticate with Microsoft Graph using an application (client) ID and secret
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$body = @{
    grant_type = "client_credentials"
    scope = "https://graph.microsoft.com/.default"
    client_id = $appId
    client_secret = $appSecret
}
$authResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body
$accessToken = $authResponse.access_token

# Get all licensed users in the tenant
$usersEndpoint = "https://graph.microsoft.com/v1.0/users?$select=displayName,userPrincipalName,passwordPolicies"
$usersResponse = Invoke-RestMethod -Method Get -Uri $usersEndpoint -Headers @{Authorization = "Bearer $accessToken"}

# Calculate the password expiration date for each user and send an email with the reminder
foreach ($user in $usersResponse.value) {
    # Skip any users who do not have a password policy set (e.g. service accounts)
    if ($user.passwordPolicies.Count -eq 0) {
        continue
    }

    $passwordExpirationDate = [DateTime]::FromFileTimeUtc($user.passwordPolicies[0].expirationDateTime)

    # Check if the password will expire within the next 14 days
    $daysUntilExpiration = ($passwordExpirationDate - (Get-Date)).Days
    if ($daysUntilExpiration -le 14) {
        $displayName = $user.displayName
        $toAddress = $user.userPrincipalName

        # Replace the placeholders in the HTML body with the user information
        $htmlBodyWithUserInfo = $htmlBody -replace "\[DisplayName\]", $displayName -replace "\[PasswordExpirationDate\]", $passwordExpirationDate.ToShortDateString()

        # Send the email
        $smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
        $smtpClient.EnableSsl = $true
        $smtpClient.Credentials = New-Object System.Net.NetworkCredential($smtpUsername, $smtpPassword)
        $mailMessage = New-Object System.Net.Mail.MailMessage($fromAddress, $toAddress, $subject, $htmlBodyWithUserInfo)
        $mailMessage.IsBodyHtml = $true
        $smtpClient.Send($mailMessage)

        Write-Host "Reminder email sent to $toAddress"
    }
}