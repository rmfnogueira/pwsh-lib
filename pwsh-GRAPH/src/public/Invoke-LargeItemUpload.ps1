function Invoke-LargeItemUpload {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object]
        $UploadSession
    )
  
    #### Send bytes to the upload session
    $Filepath = (Get-LatestItem).Fullname  
    $fileInBytes = [System.IO.File]::ReadAllBytes($Filepath)
    $fileLength = $fileInBytes.Length
    
    $headers = @{
      'Content-Range' = "bytes 0-$($fileLength-1)/$fileLength"
    }
    $response = Invoke-RestMethod -Method 'Put' -Uri $UploadSession.uploadUrl -Body $fileInBytes -Headers $headers
    # return $response
  } # Invoke-LargeItemUpload