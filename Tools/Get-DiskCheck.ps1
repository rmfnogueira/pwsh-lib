function Get-DiskCheck {
[cmdletbinding(DefaultParameterSetName = "name")]
Param(
    [Parameter(
        Position = 0, 
        Mandatory,
        HelpMessage = "Enter a computer name to check",
        ParameterSetName = "name",
        ValueFromPipeline
    )]
    [Alias("cn")]
    [ValidateNotNullorEmpty()]
    [string[]]$Computername,

    [Parameter(
        Mandatory,
        HelpMessage = "Enter the path to a text file of computer names",
        ParameterSetName = "file"
    )]
    [ValidateScript( {
            if (Test-Path $_) {
                $True
            }
            else {
                Throw "Cannot validate path $_"
            }
        })]
    [ValidatePattern("\.txt$")]
    [string]$Path,

    [ValidateRange(10, 50)]
    [int]$Threshhold = 25,

    [ValidateSet("C:", "D:", "E:", "F:")]
    [string]$Drive = "C:",

    [switch]$Test
)

Begin {
    Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"

    $cimParam = @{
        Classname    = "Win32_LogicalDisk"
        Filter       = "DeviceID='$Drive'"
        Computername = $Null
        ErrorAction  = "Stop"
    }
} #begin

Process {

    if ($PSCmdlet.ParameterSetName -eq 'name') {
        $names = $Computername
    }
    else {
        #get list of names and trim off any extra spaces
        Write-Verbose "[PROCESS] Importing names from $path"
        $names = Get-Content -Path $path |
        Where-Object {$_ -match "\w+"} |
        ForEach-Object {$_.Trim()}
    }

    if ($test) {
        Write-Verbose "[PROCESS] Testing connectivity"
        #ignore errors for offline computers
        $names = $names |
        Where-Object {Test-WSMan $_ -ErrorAction SilentlyContinue}
    }

    foreach ($computer in $names) {
        $cimParam.Computername = $Computer
        Write-Verbose "[PROCESS] Querying $($computer.toUpper())"
        Try {
            $data = Get-CimInstance @cimParam

            #write custom result to the pipeline
            $data | Select-Object -property PSComputername,
            DeviceID, Size, Freespace,
            @{Name = "PctFree"; Expression = {
            [math]::Round(($_.freespace / $_.size) * 100, 2)}
            },
            @{Name = "OK"; Expression = {
            [int]$p = ($_.freespace / $_.size) * 100
             if ($p -ge $Threshhold) {
                $True
             }
             else {
                $false
             }
            } 
            }, @{Name = "Date"; Expression = {(Get-Date)}}
        }
        Catch {
            Write-Warning "[$($computer.toUpper())] Failed."
            Write-Warning  $_.Exception.message
        }
    } #foreach computer
} #process

End {
    Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
} #end

} #Get-DiskCheck
