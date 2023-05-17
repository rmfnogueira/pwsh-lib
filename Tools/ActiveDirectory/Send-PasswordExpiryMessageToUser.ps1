function Send-PasswordExpiryMessageToUser {
    [CmdletBinding()]
    Param(
        [Paramter(ValueFromPipeline=$True)]
        [object[]]$InputObject,

        [Parameter(Mandatory=$True)]
        [string]$From,

        [Parameter(Mandatory=$True)]
        [string]$smtpServer
    )
    begin {
    }
    process {
        ForEach ($user in $InputObject) {
            $subject = "Password expires $($user.UserMessage)"
            $body = " @"
                Caro utilizador: $($user.name),
                A sua password irá expirar $($user.UserMessage).
                Por favor altere a mesma com a maior brevidade possível.
              "@ "

            if ($PSCmdlet.Shouldprocess("send expiry notice","$($user.name) who expires $($user.usermessage)")) {
                    Send-MailMessage -smtpServer $smtpServer -from $from -to $user.emailaddress -subject $subject -body $body  -priority High 
            }

            Write-Output $user
        } #foreach
    } #process
}#Send-PasswordExpiryMessageToUser