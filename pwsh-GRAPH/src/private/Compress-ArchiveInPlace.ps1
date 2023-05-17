function Compress-ArchiveInPlace {
    [CmdletBinding()]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.FileInfo]
        $Archive = (Get-LatestItem)
    )
    begin {
        $Path                   = $Archive.FullName
        $Dir                    = ($Archive.FullName).Substring("",11)
        $Name                   = $Archive.basename
        $DestinationPath        = [System.String]::Concat("$dir","$name",".zip")
        $params = @{
            'Path'              = $Path
            'DestinationPath'   = $DestinationPath
            'Force'             = $true
        }
    }
    process {
        Compress-Archive @params
    }
    end {
    }
} # Compress-ArchiveInPlace