function New-EncryptedCredentialsFromFile {
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
        [string]$FilePath = "$PSScriptRoot\EncryptedPassword.txt",
        
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Username
    )
    
    $EncryptedPassword = Get-Content $FilePath | ConvertTo-SecureString -Key (1..16)

    $global:Credential = [System.Management.Automation.PSCredential]::new("$($Username)", $EncryptedPassword)
    Write-Output $global:Credential
}#New-EncryptedCredentialsFromFile