function Get-ADUserImmutableID {
    param (
        [ValidateNotNullOrEmpty()]
        [parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0)]
        
        [string[]]
        $SamAccountName = $(Throw 'Must provide -SamAccountName'),

        [parameter(
            HelpMessage = 'Enter the path where you wish to output the file.'
        )]
        [ValidateScript({ Test-Path $_ })]
        [string]
        $FilePath = $(Throw 'Parameter -FilePath mandatory')
    )
    begin {
        $time = [System.DateTime]::Now.ToShortTimeString()
        $Output = "$($FilePath)\$($SamAccountName)ImmutableID.txt"
    }

    process {
        foreach ($SAM in $SamAccountName) {
            $Params = @{
                FilePath     = 'ldifde.exe'
                ArgumentList = "-r (SamAccountName=$SAM) -f $Output"
            }
            try {
                Write-Verbose "Writing $SamAccountName ImmutableID to c:\scripts\$SAM-$time-ImmutableIDInfo.txt"
                Start-process @Params
            }
            catch {
                throw $_
            }
        }
    }
    end {
    }
}#Get-ADUserImmutableID