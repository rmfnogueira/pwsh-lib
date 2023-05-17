function Install-Software {
    #MSI Package Installation Script
    #GET EXE IDEA FROM MS TEAMS MODULE
    
    param (
        [Parameter(ValueFromPipeline)]
        [String]
        $InstallerPath,

        [Parameter()]
        [string]
        $SourcePath,

        [parameter(ValueFromPipeline)]
        [String]
        $DestinationPath,

        [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string]$ComputerName

    )        
    BEGIN {
        if (!Test-Path N:) {
            New-PSDrive -Name N -PSProvider FileSystem -Root "hardcoded_path_or_parameterize" -Credential (Get-Credential)
        }
    }
    PROCESS {
        foreach ($server in $servers) {

            #If exe: setup executable (.exe) path and custom args for exe as params
            #If MSI setup MSI executable path and custom args for msi as params
            #working for winrm only
            Try {
                if (!(Test-Path "\\$ComputerName\C$\Temp")) {
                    New-Item -Path "\\$ComputerName\C$\Temp" -Type Directory
                }
                Copy-Item "\\$SourcePath" -Destination "\\$ComputerName\C$\Temp"
                Invoke-Command -ComputerName $ComputerName -ScriptBlock { 
                    Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i path_to_msi.msi /quiet /qn /log c:\temp\name.txt' -Wait }
                
                
            }
            Catch {
                throw $_ 
            } #tryCatch
        } #foreach
    }#process
    END {
        foreach ($comp in $ComputerName) {
            Remove-Item "\\$ComputerName\C$\Temp" -Recurse -Force
        }
    }
}#Install-Software