BeforeAll {
    Import-Module "$PSScriptRoot/../pwsh-AD.psm1" -Force # -verbose
}

Describe 'Move-ADObjectOU' {
    It 'should throw if object class is not "computer"' {
        Mock Get-ADComputer {
            return @{
                Enabled           = $true
                DistinguishedName = 'CN=TEST1,OU=TEST,DC=TEST,DC=COM'
            }
            # $move = Move-ADComputerOUEscola
            $PC.enabled | Should -Be $true
        }  
    }
}