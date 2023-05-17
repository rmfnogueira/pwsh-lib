# Awesome Module, in PSGallery, not authored by me but as was usefull in many situations ended up here.
using namespace System.Collections.Generic
#Region '.\private\ConvertToNetwork.ps1' 0
function ConvertToNetwork {
    <#
    .SYNOPSIS
        Converts IP address formats to a set a known styles.
    .DESCRIPTION
        ConvertToNetwork ensures consistent values are recorded from parameters which must handle differing addressing formats. This Cmdlet allows all other the other functions in this module to offload parameter handling.
    .NOTES
        Change log:
            05/03/2016 - Chris Dent - Refactored and simplified.
            14/01/2014 - Chris Dent - Created.
    #>

    [CmdletBinding()]
    [OutputType('Indented.Net.IP.Network')]
    param (
        # Either a literal IP address, a network range expressed as CIDR notation, or an IP address and subnet mask in a string.
        [Parameter(Mandatory = $true, Position = 1)]
        [String]$IPAddress,

        # A subnet mask as an IP address.
        [Parameter(Position = 2)]
        [AllowNull()]
        [String]$SubnetMask
    )

    $validSubnetMaskValues = @(
        "0.0.0.0", "128.0.0.0", "192.0.0.0",
        "224.0.0.0", "240.0.0.0", "248.0.0.0", "252.0.0.0",
        "254.0.0.0", "255.0.0.0", "255.128.0.0", "255.192.0.0",
        "255.224.0.0", "255.240.0.0", "255.248.0.0", "255.252.0.0",
        "255.254.0.0", "255.255.0.0", "255.255.128.0", "255.255.192.0",
        "255.255.224.0", "255.255.240.0", "255.255.248.0", "255.255.252.0",
        "255.255.254.0", "255.255.255.0", "255.255.255.128", "255.255.255.192",
        "255.255.255.224", "255.255.255.240", "255.255.255.248", "255.255.255.252",
        "255.255.255.254", "255.255.255.255"
    )

    $network = [PSCustomObject]@{
        IPAddress  = $null
        SubnetMask = $null
        MaskLength = 0
        PSTypeName = 'Indented.Net.IP.Network'
    }

    # Override ToString
    $network | Add-Member ToString -MemberType ScriptMethod -Force -Value {
        '{0}/{1}' -f $this.IPAddress, $this.MaskLength
    }

    if (-not $PSBoundParameters.ContainsKey('SubnetMask') -or $SubnetMask -eq '') {
        $IPAddress, $SubnetMask = $IPAddress.Split([Char[]]'\/ ', [StringSplitOptions]::RemoveEmptyEntries)
    }

    # IPAddress

    while ($IPAddress.Split('.').Count -lt 4) {
        $IPAddress += '.0'
    }

    if ([IPAddress]::TryParse($IPAddress, [Ref]$null)) {
        $network.IPAddress = [IPAddress]$IPAddress
    } else {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [ArgumentException]'Invalid IP address.',
            'InvalidIPAddress',
            'InvalidArgument',
            $IPAddress
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    # SubnetMask

    if ($null -eq $SubnetMask -or $SubnetMask -eq '') {
        $network.SubnetMask = [IPAddress]$validSubnetMaskValues[32]
        $network.MaskLength = 32
    } else {
        $maskLength = 0
        if ([Int32]::TryParse($SubnetMask, [Ref]$maskLength)) {
            if ($MaskLength -ge 0 -and $maskLength -le 32) {
                $network.SubnetMask = [IPAddress]$validSubnetMaskValues[$maskLength]
                $network.MaskLength = $maskLength
            } else {
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [ArgumentException]'Mask length out of range (expecting 0 to 32).',
                    'InvalidMaskLength',
                    'InvalidArgument',
                    $SubnetMask
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        } else {
            while ($SubnetMask.Split('.').Count -lt 4) {
                $SubnetMask += '.0'
            }
            $maskLength = $validSubnetMaskValues.IndexOf($SubnetMask)

            if ($maskLength -ge 0) {
                $Network.SubnetMask = [IPAddress]$SubnetMask
                $Network.MaskLength = $maskLength
            } else {
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    [ArgumentException]'Invalid subnet mask.',
                    'InvalidSubnetMask',
                    'InvalidArgument',
                    $SubnetMask
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }

    $network
}
#EndRegion '.\private\ConvertToNetwork.ps1' 115
#Region '.\private\GetPermutation.ps1' 0
function GetPermutation {
    <#
    .SYNOPSIS
        Gets permutations of an IP address expansion expression.

    .DESCRIPTION
        Gets permutations of an IP address expansion expression.
    #>

    [CmdletBinding()]
    param (
        [PSTypeName('ExpansionGroupInfo')]
        [Object[]]$Group,

        [String]$BaseAddress,

        [Int32]$Index
    )

    foreach ($value in $Group[$Index].ReplaceWith) {
        $octets = $BaseAddress -split '\.'
        $octets[$Group[$Index].Position] = $value
        $address = $octets -join '.'

        if ($Index -lt $Group.Count - 1) {
            $address = GetPermutation $Group -Index ($Index + 1) -BaseAddress $address
        }
        $address
    }
}
#EndRegion '.\private\GetPermutation.ps1' 31
#Region '.\private\NewSubnet.ps1' 0
function NewSubnet {
    <#
    .SYNOPSIS
        Creates an IP subnet object.

    .DESCRIPTION
        Creates an IP subnet object.

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $NetworkAddress,

        $BroadcastAddress,

        $SubnetMask,

        $MaskLength
    )

    if ($NetworkAddress -isnot [IPAddress]) {
        $NetworkAddress = ConvertTo-DottedDecimalIP $NetworkAddress
    }
    if ($BroadcastAddress -and $BroadcastAddress -isnot [IPAddress]) {
        $BroadcastAddress = ConvertTo-DottedDecimalIP $BroadcastAddress
    }
    if ($NetworkAddress -eq $BroadcastAddress) {
        $SubnetMask = '255.255.255.255'
        $MaskLength = 32
        $HostAddresses = 0
    } else {
        # One of these will be provided
        if (-not $SubnetMask) {
            $SubnetMask = ConvertTo-Mask $MaskLength
        }
        if (-not $MaskLength) {
            $MaskLength = ConvertTo-MaskLength $SubnetMask
        }
        $HostAddresses = [Math]::Pow(2, (32 - $MaskLength)) - 2
        if ($HostAddresses -lt 0) {
            $HostAddresses = 0
        }
    }
    if (-not $BroadcastAddress) {
        $BroadcastAddress = Get-BroadcastAddress -IPAddress $NetworkAddress -SubnetMask $SubnetMask
    }

    [PSCustomObject]@{
        Cidr             = '{0}/{1}' -f $NetworkAddress, $MaskLength
        NetworkAddress   = $NetworkAddress
        BroadcastAddress = $BroadcastAddress
        SubnetMask       = $SubnetMask
        MaskLength       = $MaskLength
        HostAddresses    = $HostAddresses
        PSTypeName       = 'Indented.Net.IP.Subnet'
    } | Add-Member ToString -MemberType ScriptMethod -Force -PassThru -Value {
        return $this.Cidr
    }
}
#EndRegion '.\private\NewSubnet.ps1' 62
#Region '.\public\ConvertFrom-HexIP.ps1' 0
function ConvertFrom-HexIP {
    <#
    .SYNOPSIS
        Converts a hexadecimal IP address into a dotted decimal string.

    .DESCRIPTION
        ConvertFrom-HexIP takes a hexadecimal string and returns a dotted decimal IP address. An intermediate call is made to ConvertTo-DottedDecimalIP.

    .INPUTS
        System.String

    .EXAMPLE
        ConvertFrom-HexIP c0a80001

        Returns the IP address 192.168.0.1.
    #>

    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        # An IP Address to convert.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [ValidatePattern('^(0x)?[0-9a-f]{8}$')]
        [string]$IPAddress
    )

    process {
        [IPAddress][UInt64][Convert]::ToUInt32($IPAddress, 16)
    }
}
#EndRegion '.\public\ConvertFrom-HexIP.ps1' 31
#Region '.\public\ConvertTo-BinaryIP.ps1' 0
function ConvertTo-BinaryIP {
    <#
    .SYNOPSIS
        Converts a Decimal IP address into a binary format.

    .DESCRIPTION
        ConvertTo-BinaryIP uses System.Convert to switch between decimal and binary format. The output from this function is dotted binary.

    .INPUTS
        System.Net.IPAddress

    .EXAMPLE
        ConvertTo-BinaryIP 1.2.3.4

        Convert an IP address to a binary format.
    #>

    [CmdletBinding()]
    [OutputType([String])]
    param (
        # An IP Address to convert.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [IPAddress]$IPAddress
    )

    process {
        $binary = foreach ($byte in $IPAddress.GetAddressBytes()) {
            [Convert]::ToString($byte, 2).PadLeft(8, '0')
        }
        $binary -join '.'
    }
}
#EndRegion '.\public\ConvertTo-BinaryIP.ps1' 33
#Region '.\public\ConvertTo-DecimalIP.ps1' 0
function ConvertTo-DecimalIP {
    <#
    .SYNOPSIS
        Converts a Decimal IP address into a 32-bit unsigned integer.

    .DESCRIPTION
        ConvertTo-DecimalIP takes a decimal IP, uses a shift operation on each octet and returns a single UInt32 value.

    .INPUTS
        System.Net.IPAddress

    .EXAMPLE
        ConvertTo-DecimalIP 1.2.3.4

        Converts an IP address to an unsigned 32-bit integer value.
    #>

    [CmdletBinding()]
    [OutputType([UInt32])]
    param (
        # An IP Address to convert.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline )]
        [IPAddress]$IPAddress
    )

    process {
        [UInt32]([IPAddress]::HostToNetworkOrder($IPAddress.Address) -shr 32 -band [UInt32]::MaxValue)
    }
}
#EndRegion '.\public\ConvertTo-DecimalIP.ps1' 30
#Region '.\public\ConvertTo-DottedDecimalIP.ps1' 0
function ConvertTo-DottedDecimalIP {
    <#
    .SYNOPSIS
        Converts either an unsigned 32-bit integer or a dotted binary string to an IP Address.

    .DESCRIPTION
         ConvertTo-DottedDecimalIP uses a regular expression match on the input string to convert to an IP address.

    .INPUTS
        System.String

    .EXAMPLE
        ConvertTo-DottedDecimalIP 11000000.10101000.00000000.00000001

        Convert the binary form back to dotted decimal, resulting in 192.168.0.1.

    .EXAMPLE
        ConvertTo-DottedDecimalIP 3232235521

        Convert the decimal form back to dotted decimal, resulting in 192.168.0.1.
    #>

    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        # A string representation of an IP address from either UInt32 or dotted binary.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string]$IPAddress
    )

    process {
        try {
            [Int64]$value = 0
            if ([Int64]::TryParse($IPAddress, [Ref]$value)) {
                return [IPAddress]([IPAddress]::NetworkToHostOrder([Int64]$value) -shr 32 -band [UInt32]::MaxValue)
            } else {
                [IPAddress][UInt64][Convert]::ToUInt32($IPAddress.Replace('.', ''), 2)
            }
        } catch {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [ArgumentException]'Cannot convert this format.',
                'UnrecognisedFormat',
                'InvalidArgument',
                $IPAddress
            )
            Write-Error -ErrorRecord $errorRecord
        }
    }
}
#EndRegion '.\public\ConvertTo-DottedDecimalIP.ps1' 50
#Region '.\public\ConvertTo-HexIP.ps1' 0
function ConvertTo-HexIP {
    <#
    .SYNOPSIS
        Convert a dotted decimal IP address into a hexadecimal string.

    .DESCRIPTION
        ConvertTo-HexIP takes a dotted decimal IP and returns a single hexadecimal string value.

    .INPUTS
        System.Net.IPAddress

    .EXAMPLE
        ConvertTo-HexIP 192.168.0.1

        Returns the hexadecimal string c0a80001.
    #>

    [CmdletBinding()]
    [OutputType([String])]
    param (
        # An IP Address to convert.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [IPAddress]$IPAddress
    )

    process {
        $bytes = $IPAddress.GetAddressBytes()
        [Array]::Reverse($bytes)
        '{0:x8}' -f [BitConverter]::ToUInt32($bytes, 0)
    }
}
#EndRegion '.\public\ConvertTo-HexIP.ps1' 32
#Region '.\public\ConvertTo-Mask.ps1' 0
function ConvertTo-Mask {
    <#
    .SYNOPSIS
        Convert a mask length to a dotted-decimal subnet mask.

    .DESCRIPTION
        ConvertTo-Mask returns a subnet mask in dotted decimal format from an integer value ranging between 0 and 32.

        ConvertTo-Mask creates a binary string from the length, converts the string to an unsigned 32-bit integer then calls ConvertTo-DottedDecimalIP to complete the operation.

    .INPUTS
        System.Int32

    .EXAMPLE
        ConvertTo-Mask 24

        Returns the dotted-decimal form of the mask, 255.255.255.0.
    #>

    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        # The number of bits which must be masked.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [Alias('Length')]
        [ValidateRange(0, 32)]
        [byte]$MaskLength
    )

    process {
        [IPAddress][UInt64][Convert]::ToUInt32(('1' * $MaskLength).PadRight(32, '0'), 2)
    }
}
#EndRegion '.\public\ConvertTo-Mask.ps1' 34
#Region '.\public\ConvertTo-MaskLength.ps1' 0
function ConvertTo-MaskLength {
    <#
    .SYNOPSIS
        Convert a dotted-decimal subnet mask to a mask length.

    .DESCRIPTION
        A count of the number of 1's in a binary string.

    .INPUTS
        System.Net.IPAddress

    .EXAMPLE
        ConvertTo-MaskLength 255.255.255.0

        Returns 24, the length of the mask in bits.
    #>

    [CmdletBinding()]
    [OutputType([Int32])]
    param (
        # A subnet mask to convert into length.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [Alias("Mask")]
        [IPAddress]$SubnetMask
    )

    process {
        [Convert]::ToString([IPAddress]::HostToNetworkOrder($SubnetMask.Address), 2).Replace('0', '').Length
    }
}
#EndRegion '.\public\ConvertTo-MaskLength.ps1' 31
#Region '.\public\ConvertTo-Subnet.ps1' 0
function ConvertTo-Subnet {
    <#
    .SYNOPSIS
        Convert a start and end IP address to the closest matching subnet.

    .DESCRIPTION
        ConvertTo-Subnet attempts to convert a starting and ending IP address from a range to the closest subnet.

    .EXAMPLE
        ConvertTo-Subnet -Start 0.0.0.0 -End 255.255.255.255

        Returns a subnet object describing 0.0.0.0/0.
    .EXAMPLE
        ConvertTo-Subnet -Start 192.168.0.1 -End 192.168.0.129

        Returns a subnet object describing 192.168.0.0/24. The smallest subnet which can encapsulate the start and end range.
    .EXAMPLE
        ConvertTo-Subnet 10.0.0.23/24

        Returns a subnet object describing 10.0.0.0/24.
    .EXAMPLE
        ConvertTo-Subnet 10.0.0.23 255.255.255.0

        Returns a subnet object describing 10.0.0.0/24.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromIPAndMask')]
    [OutputType('Indented.Net.IP.Subnet')]
    param (
        # Any IP address in the subnet.
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'FromIPAndMask')]
        [string]$IPAddress,

        # A subnet mask.
        [Parameter(Position = 2, ParameterSetName = 'FromIPAndMask')]
        [string]$SubnetMask,

        # The first IP address from a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]$Start,

        # The last IP address from a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]$End
    )

    if ($PSCmdlet.ParameterSetName -eq 'FromIPAndMask') {
        try {
            $network = ConvertToNetwork @PSBoundParameters
            NewSubnet -NetworkAddress (Get-NetworkAddress $network.ToString()) -MaskLength $network.MaskLength
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    } elseif ($PSCmdlet.ParameterSetName -eq 'FromStartAndEnd') {
        if ($Start -eq $End) {
            $MaskLength = 32
        } else {
            $DecimalStart = ConvertTo-DecimalIP $Start
            $DecimalEnd = ConvertTo-DecimalIP $End

            if ($DecimalEnd -lt $DecimalStart) {
                $Start = $End
            }

            # Find the point the binary representation of each IP address diverges
            $i = 32
            do {
                $i--
            } until (($DecimalStart -band ([UInt32]1 -shl $i)) -ne ($DecimalEnd -band ([UInt32]1 -shl $i)))

            $MaskLength = 32 - $i - 1
        }

        NewSubnet -NetworkAddress (Get-NetworkAddress $Start -SubnetMask $MaskLength) -MaskLength $MaskLength
    }
}
#EndRegion '.\public\ConvertTo-Subnet.ps1' 77
#Region '.\public\Get-BroadcastAddress.ps1' 0
function Get-BroadcastAddress {
    <#
    .SYNOPSIS
        Get the broadcast address for a network range.

    .DESCRIPTION
        Get-BroadcastAddress returns the broadcast address for a subnet by performing a bitwise AND operation against the decimal forms of the IP address and inverted subnet mask.

    .INPUTS
        System.String

    .EXAMPLE
        Get-BroadcastAddress 192.168.0.243 255.255.255.0

        Returns the address 192.168.0.255.

    .EXAMPLE
        Get-BroadcastAddress 10.0.9/22

        Returns the address 10.0.11.255.

    .EXAMPLE
        Get-BroadcastAddress 0/0

        Returns the address 255.255.255.255.

    .EXAMPLE
        Get-BroadcastAddress "10.0.0.42 255.255.255.252"

        Input values are automatically split into IP address and subnet mask. Returns the address 10.0.0.43.
    #>

    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        # Either a literal IP address, a network range expressed as CIDR notation, or an IP address and subnet mask in a string.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string]$IPAddress,

        # A subnet mask as an IP address.
        [Parameter(Position = 2)]
        [string]$SubnetMask
    )

    process {
        try {
            $network = ConvertToNetwork @PSBoundParameters

            $networkAddress = [IPAddress]($network.IPAddress.Address -band $network.SubnetMask.Address)

            return [IPAddress](
                $networkAddress.Address -bor
                -bnot $network.SubnetMask.Address -band
                -bnot ([Int64][UInt32]::MaxValue -shl 32)
            )
        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}
#EndRegion '.\public\Get-BroadcastAddress.ps1' 61
#Region '.\public\Get-NetworkAddress.ps1' 0
function Get-NetworkAddress {
    <#
    .SYNOPSIS
        Get the network address for a network range.

    .DESCRIPTION
        Get-NetworkAddress returns the network address for a subnet by performing a bitwise AND operation against the decimal forms of the IP address and subnet mask.

    .INPUTS
        System.String

    .EXAMPLE
        Get-NetworkAddress 192.168.0.243 255.255.255.0

        Returns the address 192.168.0.0.

    .EXAMPLE
        Get-NetworkAddress 10.0.9/22

        Returns the address 10.0.8.0.

    .EXAMPLE
        Get-NetworkAddress "10.0.23.21 255.255.255.224"

        Input values are automatically split into IP address and subnet mask. Returns the address 10.0.23.0.
    #>

    [CmdletBinding()]
    [OutputType([IPAddress])]
    param (
        # Either a literal IP address, a network range expressed as CIDR notation, or an IP address and subnet mask in a string.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string]$IPAddress,

        # A subnet mask as an IP address.
        [Parameter(Position = 2)]
        [string]$SubnetMask
    )

    process {
        try {
            $network = ConvertToNetwork @PSBoundParameters

            return [IPAddress]($network.IPAddress.Address -band $network.SubnetMask.Address)
        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}
#EndRegion '.\public\Get-NetworkAddress.ps1' 50
#Region '.\public\Get-NetworkRange.ps1' 0
function Get-NetworkRange {
    <#
    .SYNOPSIS
        Get a list of IP addresses within the specified network.

    .DESCRIPTION
        Get-NetworkRange finds the network and broadcast address as decimal values then starts a counter between the two, returning IPAddress for each.

    .INPUTS
        System.String

    .EXAMPLE
        Get-NetworkRange 192.168.0.0 255.255.255.0

        Returns all IP addresses in the range 192.168.0.0/24.

    .EXAMPLE
        Get-NetworkRange 10.0.8.0/22

        Returns all IP addresses in the range 192.168.0.0 255.255.252.0.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromIPAndMask')]
    [OutputType([IPAddress])]
    param (
        # Either a literal IP address, a network range expressed as CIDR notation, or an IP address and subnet mask in a string.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ParameterSetName = 'FromIPAndMask')]
        [string]$IPAddress,

        # A subnet mask as an IP address.
        [Parameter(Position = 2, ParameterSetName = 'FromIPAndMask')]
        [string]$SubnetMask,

        # Include the network and broadcast addresses when generating a network address range.
        [Parameter(ParameterSetName = 'FromIPAndMask')]
        [switch]$IncludeNetworkAndBroadcast,

        # The start address of a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]$Start,

        # The end address of a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]$End
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'FromIPAndMask') {
            try {
                $null = $PSBoundParameters.Remove('IncludeNetworkAndBroadcast')
                $network = ConvertToNetwork @PSBoundParameters
            } catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }

            $decimalIP = ConvertTo-DecimalIP $network.IPAddress
            $decimalMask = ConvertTo-DecimalIP $network.SubnetMask

            $startDecimal = $decimalIP -band $decimalMask
            $endDecimal = $decimalIP -bor (-bnot $decimalMask -band [UInt32]::MaxValue)

            if (-not $IncludeNetworkAndBroadcast) {
                $startDecimal++
                $endDecimal--
            }
        } else {
            $startDecimal = ConvertTo-DecimalIP $Start
            $endDecimal = ConvertTo-DecimalIP $End
        }

        for ($i = $startDecimal; $i -le $endDecimal; $i++) {
            [IPAddress]([IPAddress]::NetworkToHostOrder([Int64]$i) -shr 32 -band [UInt32]::MaxValue)
        }
    }
}
#EndRegion '.\public\Get-NetworkRange.ps1' 76
#Region '.\public\Get-NetworkSummary.ps1' 0
function Get-NetworkSummary {
    <#
    .SYNOPSIS
        Generates a summary describing several properties of a network range

    .DESCRIPTION
        Get-NetworkSummary uses many of the IP conversion commands to provide a summary of a network range from any IP address in the range and a subnet mask.

    .INPUTS
        System.String

    .EXAMPLE
        Get-NetworkSummary 192.168.0.1 255.255.255.0

    .EXAMPLE
        Get-NetworkSummary 10.0.9.43/22

    .EXAMPLE
        Get-NetworkSummary 0/0
    #>

    [CmdletBinding()]
    [OutputType('Indented.Net.IP.NetworkSummary')]
    param (
        # Either a literal IP address, a network range expressed as CIDR notation, or an IP address and subnet mask in a string.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string]$IPAddress,

        # A subnet mask as an IP address.
        [Parameter(Position = 2)]
        [string]$SubnetMask
    )

    process {
        try {
            $network = ConvertToNetwork @PSBoundParameters
        } catch {
            throw $_
        }

        $decimalIP = ConvertTo-DecimalIP $Network.IPAddress
        $decimalMask = ConvertTo-DecimalIP $Network.SubnetMask
        $decimalNetwork =  $decimalIP -band $decimalMask
        $decimalBroadcast = $decimalIP -bor (-bnot $decimalMask -band [UInt32]::MaxValue)

        $networkSummary = [PSCustomObject]@{
            NetworkAddress    = $networkAddress = ConvertTo-DottedDecimalIP $decimalNetwork
            NetworkDecimal    = $decimalNetwork
            BroadcastAddress  = ConvertTo-DottedDecimalIP $decimalBroadcast
            BroadcastDecimal  = $decimalBroadcast
            Mask              = $network.SubnetMask
            MaskLength        = $maskLength = ConvertTo-MaskLength $network.SubnetMask
            MaskHexadecimal   = ConvertTo-HexIP $network.SubnetMask
            CIDRNotation      = '{0}/{1}' -f $networkAddress, $maskLength
            HostRange         = ''
            NumberOfAddresses = $decimalBroadcast - $decimalNetwork + 1
            NumberOfHosts     = $decimalBroadcast - $decimalNetwork - 1
            Class             = ''
            IsPrivate         = $false
            PSTypeName        = 'Indented.Net.IP.NetworkSummary'
        }

        if ($networkSummary.NumberOfHosts -lt 0) {
            $networkSummary.NumberOfHosts = 0
        }
        if ($networkSummary.MaskLength -lt 31) {
            $networkSummary.HostRange = '{0} - {1}' -f @(
                (ConvertTo-DottedDecimalIP ($decimalNetwork + 1))
                (ConvertTo-DottedDecimalIP ($decimalBroadcast - 1))
            )
        }

        $networkSummary.Class = switch -regex (ConvertTo-BinaryIP $network.IPAddress) {
            '^1111' { 'E'; break }
            '^1110' { 'D'; break }
            '^11000000\.10101000' { if ($networkSummary.MaskLength -ge 16) { $networkSummary.IsPrivate = $true } }
            '^110' { 'C'; break }
            '^10101100\.0001' { if ($networkSummary.MaskLength -ge 12) { $networkSummary.IsPrivate = $true } }
            '^10' { 'B'; break }
            '^00001010' { if ($networkSummary.MaskLength -ge 8) { $networkSummary.IsPrivate = $true } }
            '^0' { 'A'; break }
        }

        $networkSummary
    }
}
#EndRegion '.\public\Get-NetworkSummary.ps1' 87
#Region '.\public\Get-Subnet.ps1' 0
#using namespace System.Collections.Generic

function Get-Subnet {
    <#
    .SYNOPSIS
        Get a list of subnets of a given size within a defined supernet.

    .DESCRIPTION
        Generates a list of subnets for a given network range using either the address class or a user-specified value.

    .EXAMPLE
        Get-Subnet 10.0.0.0 255.255.255.0 -NewSubnetMask 255.255.255.192

        Four /26 networks are returned.

    .EXAMPLE
        Get-Subnet 0/22 -NewSubnetMask 24

        64 /24 networks are returned.

    .EXAMPLE
        Get-Subnet -Start 10.0.0.1 -End 10.0.0.16

        Get the largest possible subnets between the start and end address.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromSupernet')]
    [OutputType('Indented.Net.IP.Subnet')]
    param (
        # Any address in the super-net range. Either a literal IP address, a network range expressed as CIDR notation, or an IP address and subnet mask in a string.
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'FromSupernet')]
        [string]$IPAddress,

        # The subnet mask of the network to split. Mandatory if the subnet mask is not included in the IPAddress parameter.
        [Parameter(Position = 2, ParameterSetName = 'FromSupernet')]
        [string]$SubnetMask,

        # Split the existing network described by the IPAddress and subnet mask using this mask.
        [Parameter(Mandatory, ParameterSetName = 'FromSupernet')]
        [string]$NewSubnetMask,

        # The first IP address from a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]$Start,

        # The last IP address from a range.
        [Parameter(Mandatory, ParameterSetName = 'FromStartAndEnd')]
        [IPAddress]$End
    )

    if ($PSCmdlet.ParameterSetName -eq 'FromSupernet') {
        $null = $PSBoundParameters.Remove('NewSubnetMask')
        try {
            $network = ConvertToNetwork @PSBoundParameters
            $newNetwork = ConvertToNetwork 0 $NewSubnetMask
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }

        if ($network.MaskLength -gt $newNetwork.MaskLength) {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [ArgumentException]'The subnet mask of the new network is shorter (masks fewer addresses) than the subnet mask of the existing network.',
                'NewSubnetMaskTooShort',
                'InvalidArgument',
                $newNetwork.MaskLength
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $numberOfNets = [Math]::Pow(2, ($newNetwork.MaskLength - $network.MaskLength))
        $numberOfAddresses = [Math]::Pow(2, (32 - $newNetwork.MaskLength))

        $decimalAddress = ConvertTo-DecimalIP (Get-NetworkAddress $network.ToString())
        for ($i = 0; $i -lt $numberOfNets; $i++) {
            $networkAddress = ConvertTo-DottedDecimalIP $decimalAddress

            NewSubnet -NetworkAddress $networkAddress -MaskLength $newNetwork.MaskLength

            $decimalAddress += $numberOfAddresses
        }
    } elseif ($PSCmdlet.ParameterSetName -eq 'FromStartAndEnd') {
        $range = @{ Start = ConvertTo-DecimalIP $Start; End = ConvertTo-DecimalIP $End; Type = 'Whole' }
        if ($range['Start'] -gt $range['End']) {
            # Could just swap them, but it implies a problem with the request
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [ArgumentException]'The end address in the range falls before the start address.',
                'InvalidNetworkRange',
                'InvalidArgument',
                $range
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $inputQueue = [Queue[object]]::new()
        $inputQueue.Enqueue($range)

        # Find an initial maximum number of host bits. Reduces work in the main loops.
        $maximumHostBits = 32
        do {
            $maximumHostBits--
        } until (($range['Start'] -band ([UInt32]1 -shl $maximumHostBits)) -ne ($range['End'] -band ([UInt32]1 -shl $maximumHostBits)))
        $maximumHostBits++

        # Guards against infinite loops when I've done something wrong
        $maximumIterations = 200
        $iteration = 0

        $subnets = do {
            $range =  $inputQueue.Dequeue()
            $rangeSize = $range['End'] - $range['Start'] + 1

            if ($rangeSize -eq 1) {
                NewSubnet -NetworkAddress $range['Start'] -BroadcastAddress $range['End']
                continue
            }
            $subnetStart = $subnetEnd = $null
            for ($hostBits = $maximumHostBits; $hostBits -gt 0; $hostBits--) {
                $subnetSize = [Math]::Pow(2, $hostBits)

                if ($subnetSize -le $rangeSize) {
                    if ($remainder = $range['Start'] % $subnetSize) {
                        $subnetStart = $range['Start'] - $remainder + $subnetSize
                    } else {
                        $subnetStart = $range['Start']
                    }
                    $subnetEnd = $subnetStart + $subnetSize - 1

                    if ($subnetEnd -gt $range['End']) {
                        continue
                    }

                    NewSubnet -NetworkAddress $subnetStart -BroadcastAddress $subnetEnd -MaskLength (32 - $hostBits)
                    break
                }
            }
            if ($subnetStart -and $subnetStart -gt $range['Start']) {
                $inputQueue.Enqueue(@{ Start = $range['Start']; End = $subnetStart - 1; Type = 'Start' } )
            }
            if ($subnetEnd -and $subnetEnd -lt $range['End']) {
                $inputQueue.Enqueue(@{ Start = $subnetEnd + 1; End = $range['End']; Type = 'End' })
            }
            $iteration++
        } while ($inputQueue.Count -and $iteration -lt $maximumIterations)

        if ($iteration -ge $maximumIterations) {
            Write-Warning 'Exceeded the maximum number of iterations while generating subnets.'
        }

        $subnets | Sort-Object { [Version]$_.NetworkAddress.ToString() }
    }
}
#EndRegion '.\public\Get-Subnet.ps1' 152
#Region '.\public\Resolve-IPAddress.ps1' 0
function Resolve-IPAddress {
    <#
    .SYNOPSIS
        Resolves an IP address expression using wildcard expressions to individual IP addresses.

    .DESCRIPTION
        Resolves an IP address expression using wildcard expressions to individual IP addresses.

        Resolve-IPAddress expands groups and values in square brackets to generate a list of IP addresses or networks using CIDR-notation.

        Ranges of values may be specied using a start and end value using "-" to separate the values.

        Specific values may be listed as a comma separated list.

    .EXAMPLE
        Resolve-IPAddress "10.[1,2].[0-2].0/24"

        Returns the addresses 10.1.0.0/24, 10.1.1.0/24, 10.1.2.0/24, 10.2.0.0/24, and so on.
    #>

    [CmdletBinding()]
    param (
        # The IPAddress expression to resolve.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string]$IPAddress
    )

    process {
        $groups = [Regex]::Matches($IPAddress, '\[(?:(?<Range>\d+(?:-\d+))|(?<Selected>(?:\d+, *)*\d+))\]|(?<All>\*)').Groups.Captures |
            Where-Object { $_ -and $_.Name -ne '0' } |
            ForEach-Object {
                $group = $_

                $values = switch ($group.Name) {
                    'Range' {
                        [int]$start, [int]$end = $group.Value -split '-'

                        if ($start, $end -gt 255) {
                            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                                [ArgumentException]::new('Value ranges to resolve must use a start and end values between 0 and 255'),
                                'RangeExpressionOutOfRange',
                                'InvalidArgument',
                                $group.Value
                            )
                            $PSCmdlet.ThrowTerminatingError($errorRecord)
                        }

                        $start..$end
                    }
                    'Selected' {
                        $values = [int[]]($group.Value -split ', *')

                        if ($values -gt 255) {
                            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                                [ArgumentException]::new('All selected values must be between 0 and 255'),
                                'SelectionExpressionOutOfRange',
                                'InvalidArgument',
                                $group.Value
                            )
                            $PSCmdlet.ThrowTerminatingError($errorRecord)
                        }

                        $values
                    }
                    'All' {
                        0..255
                    }
                }

                [PSCustomObject]@{
                    Name        = $_.Name
                    Position    = [int]$IPAddress.Substring(0, $_.Index).Split('.').Count - 1
                    ReplaceWith = $values
                    PSTypeName  = 'ExpansionGroupInfo'
                }
            }

        if ($groups) {
            GetPermutation $groups -BaseAddress $IPAddress
        } elseif (-not [IPAddress]::TryParse(($IPAddress -replace '/\d+$'), [Ref]$null)) {
            Write-Warning 'The IPAddress argument is not a valid IP address and cannot be resolved'
        } else {
            Write-Debug 'No groups found to resolve'
        }
    }
}
#EndRegion '.\public\Resolve-IPAddress.ps1' 87
#Region '.\public\Test-SubnetMember.ps1' 0
function Test-SubnetMember {
    <#
    .SYNOPSIS
        Tests an IP address to determine if it falls within IP address range.

    .DESCRIPTION
        Test-SubnetMember attempts to determine whether or not an address or range falls within another range. The network and broadcast address are calculated the converted to decimal then compared to the decimal form of the submitted address.

    .EXAMPLE
        Test-SubnetMember -SubjectIPAddress 10.0.0.0/24 -ObjectIPAddress 10.0.0.0/16

        Returns true as the subject network can be contained within the object network.

    .EXAMPLE
        Test-SubnetMember -SubjectIPAddress 192.168.0.0/16 -ObjectIPAddress 192.168.0.0/24

        Returns false as the subject network is larger the object network.

    .EXAMPLE
        Test-SubnetMember -SubjectIPAddress 10.2.3.4/32 -ObjectIPAddress 10.0.0.0/8

        Returns true as the subject IP address is within the object network.

    .EXAMPLE
        Test-SubnetMember -SubjectIPAddress 255.255.255.255 -ObjectIPAddress 0/0

        Returns true as the subject IP address is the last in the object network range.
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # A representation of the subject, the network to be tested. Either a literal IP address, a network range expressed as CIDR notation, or an IP address and subnet mask in a string.
        [Parameter(Mandatory, Position = 1)]
        [string]$SubjectIPAddress,

        # A representation of the object, the network to test against. Either a literal IP address, a network range expressed as CIDR notation, or an IP address and subnet mask in a string.
        [Parameter(Mandatory, Position = 2)]
        [string]$ObjectIPAddress,

        # A subnet mask as an IP address.
        [string]$SubjectSubnetMask,

        # A subnet mask as an IP address.
        [string]$ObjectSubnetMask
    )

    try {
        $subjectNetwork = ConvertToNetwork $SubjectIPAddress $SubjectSubnetMask
        $objectNetwork = ConvertToNetwork $ObjectIPAddress $ObjectSubnetMask
    } catch {
        throw $_
    }

    # A simple check, if the mask is shorter (larger network) then it won't be a subnet of the object anyway.
    if ($subjectNetwork.MaskLength -lt $objectNetwork.MaskLength) {
        return $false
    }

    $subjectDecimalIP = ConvertTo-DecimalIP $subjectNetwork.IPAddress
    $objectDecimalNetwork = ConvertTo-DecimalIP (Get-NetworkAddress $objectNetwork)
    $objectDecimalBroadcast = ConvertTo-DecimalIP (Get-BroadcastAddress $objectNetwork)

    # If the mask is longer (smaller network), then the decimal form of the address must be between the
    # network and broadcast address of the object (the network we test against).
    if ($subjectDecimalIP -ge $objectDecimalNetwork -and $subjectDecimalIP -le $objectDecimalBroadcast) {
        return $true
    } else {
        return $false
    }
}
#EndRegion '.\public\Test-SubnetMember.ps1' 72
