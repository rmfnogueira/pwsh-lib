function Send-Email {
    [CmdletBinding()]
    param (
      [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
     
      [string]$MailSender = "rui.mf.nogueira@edu.azores.gov.pt",
      [string]$Recipient = "rui.mf.nogueira@azores.gov.pt",
      [string]$Attachment = "C:\DadosAD\laps_module_commands.txt"
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
            "subject": "TESTE: Dados AD (.zip)",
            "body": {
              "contentType": "HTML",
              "content": "TESTE (entre tenants)<br>
                  <br>TESTE spam filtering (entre tenants)<br>"
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