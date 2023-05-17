function Add-ExpiryDataToUser {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $True)]
        [object[]]$inputObject
    )
    begin {
        $defaultMaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy -ErrorAction stop).MaxPasswordAge.Days
        Write-Verbose "Max password age $defaultMaxPasswordAge" 
    }
    process {
        ForEach ($user in $inputObject) {
            # determine max password age for user
            # this will either be based on their policy or
            # on the domain defaut if no user specific policy exists
            $passPolicy = Get-ADUserResultantPasswordPolicy $user
            if ("$($passPolicy)" -ne $null) {
                $maxAge = ($passPolicy).MaxPasswordAge.Days
            } 
            else {
                $maxAge = $defaultMaxPasswordAge
            }
            # calculate and round days to expire;
            # create and append text message to
            # user object
            $expiresOn = $user.passwordLastSet.AddDays($maxPasswordAge) 
            $daysToExpire = New-TimeSpan -Start $today -End $expiresOn 

            if (($daysToExpire.Days -eq '0') -and ($daysToExpire.TotalHours -le $timeToMidnight.TotalHours)) { 
                $user | Add-Member -Type NoteProperty -Name UserMessage -Value 'today.' 
            } 
            if (($daysToExpire.Days -eq '0') -and ($daysToExpire.TotalHours -gt $timeToMidnight.TotalHours) -or ($daysToExpire.Days -eq '1') -and ($daysToExpire.TotalHours -le $timeToMidnight2.TotalHours)) { 
                $user | Add-Member -Type NoteProperty -Name UserMessage -Value 'tomorrow.' 
            } 
            if (($daysToExpire.Days -ge '1') -and ($daysToExpire.TotalHours -gt $timeToMidnight2.TotalHours)) {
                $days = $daysToExpire.TotalDays 
                $days = [math]::Round($days) 
                $user | Add-Member -Type NoteProperty -Name UserMessage -Value "in $days days." 
            }   
            $user | Add-Member -Type NoteProperty -Name DaysToExpire -Value $daysToExpire
            $user | Add-Member -Type NoteProperty -Name ExpiresOn -Value $expiresOn

            Write-Output $user
        } #foreach
    } #process
}#Add-ExpiryDataToUser

function Send-PasswordExpiryMessageToUser {
    [CmdletBinding()]
    Param(
        [Paramter(ValueFromPipeline = $True)]
        [object[]]$InputObject,

        [Parameter(Mandatory = $True)]
        [string]$From,

        [Parameter(Mandatory = $True)]
        [string]$smtpServer
    )
    begin {
    }
    process {
        ForEach ($user in $InputObject) {
            $subject = "Password expires $($user.UserMessage)"
            $body = ' @'
            Caro utilizador: $($user.name),
            A sua password irá expirar $($user.UserMessage).
            Por favor altere a mesma com a maior brevidade possível.
            '@ '

            if ($PSCmdlet.Shouldprocess('send expiry notice', "$($user.name) who expires $($user.usermessage)")) {
                Send-MailMessage -SmtpServer $smtpServer -From $from -To $user.emailaddress -Subject $subject -Body $body -Priority High 
            }

            Write-Output $user
        } #foreach
    } #process
}#Send-PasswordExpiryMessageToUser

# One Liner to get info
Get-ADUser -filter { Enabled -eq $True -and PasswordNeverExpires -eq $False } –Properties 'DisplayName', 'msDS-UserPasswordExpiryTimeComputed' | Select-Object -Property 'Displayname', @{Name = 'ExpiryDate'; Expression = { [datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed') } }