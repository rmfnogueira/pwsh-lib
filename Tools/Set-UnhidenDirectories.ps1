function Set-UnhidenDirectorie {
    [cmdletbinding()]
    param (
        [parameter(mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName,
        Position=0)]
        [string[]]$path
    )
    begin {
    Write-Verbose "[begin]:    Starting $($MyInvocation.Mycommand)"
    #instanciate object with type/class system.io.directoryinfo from specified path
    $dir = New-Object System.IO.DirectoryInfo("$path")
    #use method to get child directories
    $folders = $dir.GetDirectories()
    }
    process {
        foreach ($item in $folders) {
    
            $item.Attributes = [System.IO.FileAttributes]::Directory
    
        }#foreach
    }#process
    end {
        Write-Verbose "[end]:     ending $($MyInvocation.Mycommand)"
    }
}#UnhideDirectories