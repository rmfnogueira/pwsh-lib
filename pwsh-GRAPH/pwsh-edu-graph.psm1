using module '.\src\models\ConnectionHandler.psm1'
using module '.\src\private\private.psm1'
using module '.\src\public\public.psm1'

#region::REQUIREMENTS
#requires -Version 7.0
#requires -RunAsAdministrator
#endregion::REQUIREMENTS

#region::SetAutomaticVariablesPreference
if ($Myinvocation.line -match '-Verbose') {
    $VerbosePreference = 'continue'
}
