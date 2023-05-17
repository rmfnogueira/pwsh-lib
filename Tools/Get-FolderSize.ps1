function Get-FolderSize {
    [CmdletBinding()]
    Param(
        [Parameter(
        Mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
        )]
        [string[]]$Path
        )

    BEGIN {}
    PROCESS {
        ForEach ($folder in $path) {
            Write-Verbose "Checking $folder"
            if (Test-Path -Path $folder) {
                Write-Verbose " + Path exists"
                    
                #turn the folder into a true FileSystem path
                $cPath = Convert-Path $Folder
        
                $params = @{
                    Path    = $cPath
                    Recurse = $true
                    File    = $true
                }
                $measure = Get-ChildItem @params |
                Measure-Object -Property Length -Sum
                [pscustomobject]@{
                    Path  = $cPath
                    Files = $measure.count
                    Bytes = $measure.sum
                }
            }
            else {
                Write-Verbose " - Path does not exist"
                [pscustomobject]@{
                    Path  = $folder
                    Files = 0
                    Bytes = 0
                }
            } #if folder exists
        } #foreach
    } #PROCESS
    END {}
}#Get-FolderSize