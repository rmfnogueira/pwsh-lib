function Export-ADUsersCsv {
    # Exportar Alunos,Docentes e Funcionarios atuais para ficheiro CSV.
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Destination,

        [string[]]
        $Searchbase
    )
    begin {
        $timestamp = Get-Date -Format dd-MM-yy
        try {
            if (!(Test-Path -Path $Destination)) {
                Write-Verbose "[Creating $Destination directory]" 
                [System.IO.Directory]::CreateDirectory($Destination)
            }
        }
        catch {
            throw "Could not create target directory, please check your path"
            break
        }

        Write-Verbose "[BEGIN]: $($MyInvocation.MyCommand)"
        Write-Verbose '[BEGIN]: Testing log file path...'
        Set-LogPath
    }
    process {
        Write-Verbose "[PROCESS] $($timestamp): Getting ADUsers"
        Get-ADUserbyOU -searchbase $searbase[0], $searchbase[1], $searchbase[2] |
        Export-Csv -Path "$Destination\ADEDU$timestamp.csv" -NoTypeInformation -Encoding utf8
    }
    end {
        Write-Verbose "[ENDING] $($timestamp): Getting ADUsers"
    }   
} #Export-ADUsersCsv