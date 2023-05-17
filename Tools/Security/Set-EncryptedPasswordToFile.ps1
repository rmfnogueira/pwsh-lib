function Set-EncryptedPasswordToFile {
    param (
        [ValidateNotNullorEmpty()]
        [string]$FilePath = "$PSScriptRoot\EncryptedPassword.txt"     
    )
    try {
        $Password = (Read-Host -AsSecureString -Prompt 'Please enter your password: ' -ErrorAction Stop)
        #Encrypt with hash
        $Encrypted = ConvertFrom-SecureString -SecureString $Password -Key (1..16)
        #Save Encrypted password to file to use later.
        $Encrypted | Set-Content $FilePath
    }
    catch {
        return $_
    }
} #Set-EncryptedCredentialsToFile