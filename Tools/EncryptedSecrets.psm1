function Set-EncryptedPasswordToFile {
    param (
        [ValidateNotNullorEmpty()]
        [string]$FilePath = "$PSScriptRoot\EncryptedPassword.txt"     
    )
    try {
        $Password = (Read-Host -AsSecureString -Prompt 'Introduza a palavra-passe a encriptar: ' -ErrorAction Stop)
        #Encrypt with hash
        $Encrypted = ConvertFrom-SecureString -SecureString $Password -Key (1..16)
        #Save Encrypted password to file to use later.
        $Encrypted | Set-Content $FilePath
    }
    catch {
        return $_
    }
} #Set-EncryptedCredentialsToFile


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
}
