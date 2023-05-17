BeforeAll {
    Import-Module "$PSScriptRoot/../pwsh-AD.psm1" -Force # -verbose
}
Describe 'Set-CustomAttributes' {
    It ' ' {}
        
    It 'Attribute value must be' {
        $extensionAttribute15 = 'TESTING'
        $extensionAttribute15 | Should -Be 'TESTING'
    }
}