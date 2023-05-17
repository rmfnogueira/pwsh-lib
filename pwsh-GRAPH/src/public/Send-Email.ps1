function Send-Email {
    [CmdletBinding()]
    param (
      [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
     
      [string]$MailSender,
      [string]$Recipient,
      [string]$Attachment
      )
    begin {
      [hashtable] $headers = [ConnectionHandler]::connect()
      #Get File Name and Base64 string
      $FileName = (Get-Item -Path $Attachment).name
      $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($Attachment))
  
      $URLsend = "https://graph.microsoft.com/v1.0/users/$MailSender/sendMail"
    
$BodyJsonsend = @"
      {
          "message": {
            "subject": "TEST",
            "body": {
              "contentType": "HTML",
              "content": "TEST (test)<br>
                  <br>TEST spam filtering<br>"
            },
            "toRecipients": [
              {
                "emailAddress": {
                  "address": "$Recipient"
                }
              }
            ]
            ,"attachments": [
              {
                "@odata.type": "#microsoft.graph.fileAttachment",
                "name": "$FileName",
                "contentType": "text/plain",
                "contentBytes": "$base64string"
              }
            ]
          },
          "saveToSentItems": "false"
        }
"@
    }
    process {
      Invoke-RestMethod -Method POST -Uri $URLsend -Headers $headers -Body $BodyJsonsend
    }
    end {}
}#Send-Email