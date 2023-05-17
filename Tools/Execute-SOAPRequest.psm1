function Start-SOAPRequest {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Xml]$SOAPRequest = @"
"@, 
        [String] $URL = 'URI',

        [String]$Method
    ) 
    Write-Host “Sending SOAP Request To Server: $URL” 
    $soapWebRequest = [System.Net.WebRequest]::Create($URL)
    $soapWebRequest.Headers.Add('SOAPAction' , "http://tempuri.org/$Method") 

    $soapWebRequest.ContentType = 'text/xml;charset="utf-8"' 
    $soapWebRequest.Accept = 'text/xml' 
    $soapWebRequest.Method = 'POST' 

    Write-Host 'Initiating Send.' 
    $requestStream = $soapWebRequest.GetRequestStream() 
    $SOAPRequest.Save($requestStream) 
    $requestStream.Close() 

    Write-Host 'Send Complete, Waiting For Response.' 
    $resp = $soapWebRequest.GetResponse() 
    $responseStream = $resp.GetResponseStream() 
    $soapReader = [System.IO.StreamReader]($responseStream) 
    $ReturnXml = [Xml] $soapReader.ReadToEnd() 
    $responseStream.Close() 

    Write-Host 'Response Received.' 

    return $ReturnXml
}

function Start-SOAPRequestFromFile {
    ( 
        [String] $SOAPRequestFile, 
        [String] $URL 
    )  
    Write-Host “Reading and converting file to XmlDocument: $SOAPRequestFile” 
    $SOAPRequest = [Xml](Get-Content $SOAPRequestFile)


    return $(Start-SOAPRequest $SOAPRequest $URL) 
}