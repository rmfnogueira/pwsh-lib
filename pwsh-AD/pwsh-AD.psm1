#requires -Modules ActiveDirectory
#Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore <when running remotely>
#requires -RunAsAdministrator

#region::CarregarFuncoes
Write-Verbose 'A carregar as funções privadas'
. $PSScriptRoot\src\private\Copy-DadosAD.ps1
. $PSScriptRoot\src\private\Edit-AllPunctuation.ps1
. $PSScriptRoot\src\private\Enable-TLS12.ps1
. $PSScriptRoot\src\private\Export-ADUsersCsv.ps1
. $PSScriptRoot\src\private\Get-LatestItem.ps1
. $PSScriptRoot\src\private\Set-LogPath.ps1
. $PSScriptRoot\src\private\Get-RandomPassword.ps1
. $PSScriptRoot\src\private\New-EduADUser.ps1
. $PSScriptRoot\src\private\Update-SrcVMs.ps1

Write-Verbose 'A carregar as funções públicas'
. $PSScriptRoot\src\public\Add-ConditionalGroupMember.ps1
. $PSScriptRoot\src\public\Get-ADUserbyOU.ps1
. $PSScriptRoot\src\public\Get-LatestCreatedObjects.ps1
. $PSScriptRoot\src\public\Import-UsersToCreateFromCSV.ps1
. $PSScriptRoot\src\public\Invoke-ADExportSGE.ps1
. $PSScriptRoot\src\public\Invoke-ADTasks.ps1
. $PSScriptRoot\src\public\Move-ADObjectOU.ps1
. $PSScriptRoot\src\public\New-ADLogon.ps1
. $PSScriptRoot\src\public\New-EduADMUser.ps1
. $PSScriptRoot\src\public\New-EduUser.ps1
. $PSScriptRoot\src\public\Set-CustomAttributes.ps1
. $PSScriptRoot\src\public\Test-ADComputerNamingRules.ps1
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

#region::SetDomainController <when running remotely>
# Write-Verbose 'Setting DomainController to E000DCSD-VM'
# $global:DC_A = 'S0204DCA.edu.azores.gov.local'
#endregion::SetDomainController

#region::SetLogFilePath
$global:LogPath = 'c:\logs\exceptions'
Set-LogPath
#endregion::SetLogFilePath

#region::Credentials <when running remotely>
#endregion::Credentials