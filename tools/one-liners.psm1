# bulk unzip 
gci *.zip | %{Expand-Archive -Path $_ -DestinationPath $_.basename}

# Allow Ping F5
New-NetFirewallRule -DisplayName "Allow Ping" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Enabled True -Action Allow -Profile Any -RemoteAddress '192.168.1.0/24','192.168.2.0/24'

# 