#22s to 24s
Import-Module Indented.Net.Ip.psm1
$subnets22 = Import-Csv c:\scripts\file.csv
$subnets24 = foreach ($sub in $subnets22) {
    Get-Subnet -IPAddress $sub.subnet_cidr -SubnetMask 22 -NewSubnetMask 24
}
$subnets24 | ForEach-Object { Add-DnsServerPrimaryZone -NetworkId $_.cidr -ReplicationScope 'Domain' }