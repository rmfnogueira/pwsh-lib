function Get-DomainControllers {
    [CmdletBinding()]
    param ($DomainDN = "DC=edu,DC=azores,DC=gov,DC=local")
    Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,$DomainDN"
}#Get-DomainControllers