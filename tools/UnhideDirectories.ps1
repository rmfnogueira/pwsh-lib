function UnhideDirectories {
    [cmdletbinding()]
    
    param (
    
        [parameter(mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName,
        Position=0)]
        [string[]]$path
    
    )
    
    BEGIN {
    Write-Verbose "[BEGIN]:    Starting $($MyInvocation.Mycommand)"
    #instanciate object with type/class system.io.directoryinfo from specified path
    $dir = New-Object System.IO.DirectoryInfo("$path")
    #use method to get child directories
    $folders = $dir.GetDirectories()
    }
    PROCESS {
        foreach ($item in $folders) {
    
            $item.Attributes = [System.IO.FileAttributes]::Directory
    
        }#foreach
    }#process
    END {
        Write-Verbose "[END]:     Ending $($MyInvocation.Mycommand)"}
}#UnhideDirectories
