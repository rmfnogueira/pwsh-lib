#requires -Modules ActiveDirectory
#Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore <when running remotely>
#requires -RunAsAdministrator

#region::CarregarFuncoes
Write-Verbose 'Source private functions'
. $PSScriptRoot/private/Copy-ADCsvExport.ps1
. $PSScriptRoot/src/private/Enable-TLS12.ps1
. $PSScriptRoot/src/private/Export-ADUsersCsv.ps1
. $PSScriptRoot/src/private/Get-LatestItem.ps1
. $PSScriptRoot/src/private/Get-RandomPassword.ps1
. $PSScriptRoot/src/private/Remove-AllPunctuation.ps1
. $PSScriptRoot/src/private/Set-ADUserPasswordExpiration.ps1
. $PSScriptRoot/src/private/Set-LogPath.ps1
. $PSScriptRoot/src/private/Update-SrcVMs.ps1

Write-Verbose 'Source public functions'
. $PSScriptRoot/src/public/Add-ConditionalGroupMember.ps1
. $PSScriptRoot/src/public/Get-ADUserbyOU.ps1
. $PSScriptRoot/src/public/Get-LatestCreatedObjects.ps1
. $PSScriptRoot/src/public/Import-UsersToCreateFromCSV.ps1
. $PSScriptRoot/src/public/Invoke-ADExport.ps1
. $PSScriptRoot/src/public/Invoke-ADTasks.ps1
. $PSScriptRoot/src/public/Move-ADObjectOU.ps1
. $PSScriptRoot/src/public/New-ADCustomUser.ps1
. $PSScriptRoot/src/public/New-AdLogon.ps1
. $PSScriptRoot/src/public/Set-CustomAttributes.ps1
. $PSScriptRoot/src/public/Test-ADComputerNamingRules.ps1
. $PSScriptRoot/src/public/Test-ADUserAttributes.ps1
#endregion::CarregarFuncoes

#region::SetAutomaticVariablesPreference
if ($Myinvocation.line -match '-Verbose') {
    $VerbosePreference = 'continue'
}
#endregion::SetAutomaticVariablesPreference

#Force TLS1.2
Enable-TLS12

# region:: Imports
Import-Module ActiveDirectory

#region::SetLogFilePath
$global:LogPath = 'c:\logs\exceptions'
Set-LogPath
#endregion::SetLogFilePath

#region::Credentials <when running remotely>
#endregion::Credentials