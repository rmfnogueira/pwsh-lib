using module "$PSScriptRoot\\pwsh-Graph\src\models\ConnectionHandler.psm1"

Write-Verbose 'A carregar as funções públicas'
. $PSScriptRoot\Get-OneDriveInfo.ps1
. $PSScriptRoot\Get-SPOInfo.ps1
. $PSScriptRoot\Invoke-LargeItemUpload.ps1
. $PSScriptRoot\New-GraphUploadSession.ps1
. $PSScriptRoot\Send-Email.ps1