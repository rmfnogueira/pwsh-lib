function Get-DomainPDC {
    Get-ADDomainController -Discover -Service PrimaryDC |
    Select-Object Name,IPv4Address,Domain,Site
}#Get-DomainPDC