function New-GraphUploadSession {
    param (
      # TODO
    )
    $headers = [ConnectionHandler]::connect()
    $site_objectid
    $Filepath = (Get-LatestItem).Fullname
    
    $URL = "https://graph.microsoft.com/v1.0/sites/$site_objectid"
    $subsite_ID = (Invoke-RestMethod -Headers $headers -Uri $URL -Method Get).ID
    
    $URL = "https://graph.microsoft.com/v1.0/sites/$subsite_ID/drives"
    $Drives = Invoke-RestMethod -Headers $headers -Uri $URL -Method Get
    
    $Document_drive_ID = ($Drives.value | Where-Object { $_.name -eq 'Documents' }).id
    $Filename = (Get-Item -path $Filepath).Name
    
    $upload_session = "https://graph.microsoft.com/v1.0/drives/$Document_drive_ID/root:/ADUsers/$($Filename):/createUploadSession"
    
    Invoke-RestMethod -Uri $upload_session -Headers $headers -Method Post
  } # New-GraphUploadSession
  