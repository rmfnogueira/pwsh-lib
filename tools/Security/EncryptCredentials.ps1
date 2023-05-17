#Set params at Global scope so they are available to all functions
[CmdletBinding()]
param (
    [String]
    $Username='user@domain.local',

    [String]
    $FilePath="$PSScriptRoot\ScriptCred.txt"
)
function Set-ScriptSecret {
    #Get password and store in variable as secureString
    $Password = Read-Host -AsSecureString -Prompt "Enter password to encrypt: "
    #Encrypt with hash
    $Encrypted = ConvertFrom-SecureString -SecureString $Password -Key (1..16)
    #Save Encrypted password to file to use later.
    $Encrypted | Set-Content $FilePath
    #Get Password from file and convert to secure string to create pscredential object
    $ScriptPassword = Get-Content $FilePath | ConvertTo-SecureString -Key (1..16)
    #Create Credential Object
    $Credential = [System.Management.Automation.PSCredential]::new($Username,$ScriptPassword)
    Write-Output $Credential
}#Set-ScriptSecret
