function Get-RemoteListeningConfiguration {
    [cmdletbinding()]
    Param(
      [Parameter(ValueFromPipeline,Mandatory)]
      [ValidateNotNullorEmpty()]
      [Alias("CN")]
      [string[]]$Computername,
      [string]$ErrorLog
    )
  
    Begin {
     Write-Information "Command = $($myinvocation.mycommand)" -Tags Meta
     Write-Information "PSVersion = $($PSVersionTable.PSVersion)" -Tags Meta
     Write-Information "User = $env:userdomain\$env:username" -tags Meta
     Write-Information "Computer = $env:computername" -tags Meta
     Write-Information "PSHost = $($host.name)" -Tags Meta
     Write-Information "Test Date = $(Get-Date)" -tags Meta
  
      WV -prefix BEGIN -message "Starting $($myinvocation.MyCommand)"
  
      $ports = [ordered]@{
        WSManHTTP  = 5985
        WSManHTTPS = 5986
        SSH        = 22
      }
  
      $testParams = @{
        Port         = ""
        Computername = ""
        WarningAction = "SilentlyContinue"
        WarningVariable = "wv"
      }
 
      $total=0

      $begin = Get-Date
    } 
    Process {
      foreach ($computer in $computername) {
        $total++
        
        $testParams.Computername = $computer.ToUpper()
  
        WV PROCESS "Testing $($testParams.Computername)"
  
        $props = [ordered]@{
          Computername = $testparams.Computername
          Date         = Get-Date
        }

        $passed = @() 
  
        $ports.GetEnumerator() | ForEach-Object {
          $testParams.Port = $_.Value
      
          WV "PROCESS" "Testing port $($testparams.port)"
          $test = Test-NetConnection @testParams
  
          WV PROCESS "Adding results"
          $props.Add($_.name, $test.TCPTestSucceeded)
          if ($test.TCPTestSucceeded) {
              $passed+=$testParams.Port
          }
  
          if (-NOT $props.Contains("RemoteAddress")) {
             wv "PROCESS" "Adding RemoteAddress $($test.remoteAddress)"
            $props.Add("RemoteAddress", $test.RemoteAddress)
          }
        }
  
        Write-Information "$($testParams.Computername) = $($passed -join ',')" `
        -Tags data
  
        $obj = New-Object -TypeName PSObject -Property $props
        Write-Output $obj
  
        #TODO: error handling and logging
      }
    } 
      End {
      $runtime = New-TimeSpan -Start $begin -End (Get-Date)
      WV END "Processed $total computer(s) in $runtime"
      WV END "Ending $($myinvocation.mycommand)"
    }
}
