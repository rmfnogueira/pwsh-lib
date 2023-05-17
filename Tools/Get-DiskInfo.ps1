function Get-DiskInfo {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True)]
        [string[]]$ComputerName
    )
    BEGIN {
        Set-StrictMode -Version Latest
    }
    PROCESS {

        ForEach ($comp in $ComputerName) {

            $params = @{'ComputerName' = $comp
                        'ClassName' = 'Win32_LogicalDisk'}
            $disks = Get-CimInstance @params

            ForEach ($disk in $disks) {

                $props = @{'ComputerName' = $comp
                           'Size' = $disk.size
                           'FreeSpace' = $disk.freespace / 1Gb
                           'Drive' = $disk.deviceid
                           'DriveType' = $disk.drivetype}

                New-Object -TypeName PSObject -Property $props

            } #foreach disk

        } #foreach computer

    } #PROCESS
    END {}
}#Get-DiskInfo