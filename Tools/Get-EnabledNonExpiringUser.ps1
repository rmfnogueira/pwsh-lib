function Get-EnabledNonExpiringUser {
    param ()
    $select_properties='Name','PasswordNeverExpires','PasswordExpired','PasswordLastSet','EmailAddress'
    $params=@{
        Filter = {(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)}
        Properties = $select_properties}
        
        Get-ADUser @params | Where-Object { $_.passwordexpired -eq $false }

}#Get-EnabledNonExpiringUser