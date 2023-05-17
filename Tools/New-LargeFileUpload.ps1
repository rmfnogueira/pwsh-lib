function New-LargeFileUpload {
  param (
    #
  )
$drive = Get-OneDriveInfo
$fileName = Get-LatestItem
$headers = [GraphEdu]::connect()

$createUploadSessionUri = "https://graph.microsoft.com/v1.0/drives/$($drive.id)/root:/${$filename}:/createUploadSession"
$uploadSession = Invoke-MgGraphRequest -Method POST -Uri $createUploadSessionUri -Body $body -ContentType 'application/json'
Write-Host $uploadSession.uploadUrl
Write-host $uploadSession.expirationDateTime
   
#### Send bytes to the upload session
$path = "$($filename.fullname)"
   
$fileInBytes = [System.IO.File]::ReadAllBytes($path)
$fileLength = $fileInBytes.Length
   
$headers = @{
  'Content-Range' = "bytes 0-$($fileLength-1)/$fileLength"
}
$response = Invoke-RestMethod -Method 'Put' -Uri $uploadSession.uploadUrl -Body $fileInBytes -Headers $headers -Authentication $headers
  
} #New-LargeFileUpload