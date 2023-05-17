function Get-UserHomeFolderInfo {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$HomeRootPath
    )
    BEGIN {}
    PROCESS {
        Write-Verbose "Enumerating $HomeRootPath"
        $params = @{
            Path      = $HomeRootPath
            Directory = $True
        }
        ForEach ($folder in (Get-ChildItem @params)) {
    
            Write-Verbose "Checking $($folder.name)"
            $params = @{
                Identity    = $folder.name
                ErrorAction = 'SilentlyContinue'
            }
            $user = Get-ADUser @params
    
        if ($user) {
                Write-Verbose " + User exists"
                $result = Get-FolderSize -Path $folder.fullname
                [pscustomobject]@{
                    User   = $folder.name
                    Path   = $folder.fullname
                    Files  = $result.files
                    Bytes  = $result.bytes
                    Status = 'OK'
                }
        }
        else {
                Write-Verbose " - User does not exist"
                [pscustomobject]@{
                    User   = $folder.name
                    Path   = $folder.fullname
                    Files  = 0
                    Bytes  = 0
                    Status = 'Orphan'
                }
        } #if user exists
    
        } #foreach
        } #PROCESS
        END {}
}#Get-UserHomeFolderInfo
