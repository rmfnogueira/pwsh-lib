function Export-ADUsersCsv {
    # Exportar Alunos,Docentes e Funcionarios atuais para ficheiro CSV.
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Destination,

        [Array]$Searchbase 
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

        Write-Verbose "[begin]: $($MyInvocation.MyCommand)"
        Write-Verbose '[begin]: Testing log file path...'
        Set-LogPath
    }
    process {
        Get-ADUserbyOU -searchbase $searchbase |
        Export-Csv -Path "$Destination\ADEDU$timestamp.csv" -NoTypeInformation -Encoding utf8
    }
    end {}   
}#Export-ADUsersCsv