function Get-RandomPassword {
    <#
.SYNOPSIS
Get-RandomPassword generates a random 8-char password using numbers, uppercase letters, lowercase letters, and special characters.

.DESCRIPTION
Get-RandomPassword generates a random 8-char password using the ASCII character set, which includes numbers (48..57), uppercase letters (65..90), lowercase letters (97..122), and special characters (33..47 + 58..64 + 91..96 + 123..126). The password is then converted to a secure string.

.OUTPUTS
System.Security.SecureString

.EXAMPLE
Get-RandomPassword
#>

    $password = -join (48..57 + 65..90 + 97..122 + 33..47 + 58..64 + 91..96 + 123..126 | 
        Get-Random -Count 8 | 
        Foreach-Object { [char]$_ })
    ConvertTo-SecureString -AsPlainText -Force $password
}