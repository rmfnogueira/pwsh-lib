function Invoke-ADExport {
  [CmdletBinding()]
  param (
    # intentionally empty
  )
  Start-Transcript
  Export-ADUsersCsv;
  Copy-ADCsvExport;
  Stop-Transcript
}