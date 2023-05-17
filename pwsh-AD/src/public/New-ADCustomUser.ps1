function New-ADCustomUser {
    [CmdletBinding()]
    param (
        # intentionally empty         
    )
    try {
        Import-UsersToCreateFromCSV |
        New-ADLogon |
        Test-ADUserAttributes -ErrorAction Stop |
        New-ADCustomUser
    }
    catch {
        $_    
    }
}