function Get-DomainControllers {
    [CmdletBinding()]
    param ($DomainDN = "DC=contoso,DC=com")
    Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,$DomainDN"
}#Get-DomainControllers