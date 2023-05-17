# For each user, it retrieves the password policies by making a GET request to the users/{id}/passwordPolicies endpoint, the response contains a validityPeriod object that has an endDateTime property, which represents the date and time when the user's password will expire. It then converts the endDateTime string to a datetime object, and calculates the number of days until the password expires.
# If the number of days until the password expires is less than or equal to the expirationThreshold constant, the script sends a notification to the user by making a POST request to the users/{id}/sendMail endpoint, passing the appropriate message in the request body.
# # Get Access Token
# try {
#     $tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
#     $body = @{
#         client_id     = $clientId
#         scope         = 'https://graph.microsoft.com/.default'
#         client_secret = $clientSecret
#         grant_type    = 'client_credentials'
#     }
#     $tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ErrorAction Stop
#     $accessToken = $tokenResponse.access_token
# }
# catch {
#     Write-Error "Error getting access token: $_"
#     return
# }

function Get-AllMSGUsers {
    param (
        # none
    )
    begin {
        $headers = [ConnectionHandler]::connect()
    }
    process {
        try {
            $usersEndpoint = "https://graph.microsoft.com/v1.0/users?$count=true&$filter=proxyAddresses/any (p:endsWith(p, 'edu.azores.gov.pt'))&$select=id,displayName,proxyaddresses,mail"
            $usersResponse = Invoke-RestMethod -Method Get -Uri $usersEndpoint -Headers $headers -ErrorAction Stop
            $users = $usersResponse.value
        }
        catch {
            Write-Error "Error getting users: $_"
            return
        }
    } end {
        return $users
    }
}

function Get-DaysToPasswordExpiration {
    param (
        #
    )
    begin {
            
        # Configure headers
        $headers = [ConnectionHandler]::connect()
    }
    process {
        foreach ($user in $users) {
            try {
                $passwordPoliciesEndpoint = "https://graph.microsoft.com/v1.0/users/$($user.id)/passwordPolicies"
                $passwordPoliciesResponse = Invoke-RestMethod -Method Get -Uri $passwordPoliciesEndpoint -Headers $headers -ErrorAction Stop
                $passwordExpirationDate = [datetime]::parse($passwordPoliciesResponse.validityPeriod.endDateTime)
                $daysUntilExpiration = ($passwordExpirationDate - (Get-Date)).days
            }
            catch {
                Write-Error "Error getting password policies for user $($user.userPrincipalName): $_"
            }
        }
    }
    end {
        return $daysUntilExpiration
    }
}

function Send-PasswordAboutToExpireNotification {
    param (
        # 
    )
    begin {
        $expirationThreshold = 15
        $headers = [ConnectionHandler]::connect()
    }
    process {
        if ($daysUntilExpiration -le $expirationThreshold) {
            try {
                $email = $user.mail
                $body = @{
                    subject      = "$($email): Your password is about to expire"
                    toRecipients = '' # @(@{emailAddress = @{address = '' } })
                    body         = @{content = "Your password will expire in $daysUntilExpiration days, please change it." }
                } | ConvertTo-Json
                $notificationEndpoint = "https://graph.microsoft.com/v1.0/users/$($user.id)/sendMail"
                Invoke-RestMethod -Method Post -Uri $notificationEndpoint -Headers $headers -Body $body -ErrorAction Stop
            }
            catch {
                Write-Error "Error sending notification to user $($user.userPrincipalName): $_"
            }
        }
    }
    end {}
}



