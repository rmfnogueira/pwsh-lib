BeforeAll {
    Import-Module "$PSScriptRoot/../pwsh-edu-ad.psm1" -Force # -verbose
}

Describe 'Add-ConditionalGroupMember' {
    
    It 'Should Throw if there are no users to be added' {
        Mock Get-ADUser {
            return @{}
            $criados_ult_30min = Get-ADUser
            $criados_ult_30min | Should throw
        }
    }

    It 'Should NOT throw if there are no users to be added' {
        Mock Get-ADUser {
            return @{
                DistinguishedName = 'CN=TEST1,OU=TEST,DC=TEST,DC=COM'
                PSTypeName        = 'Microsoft.ActiveDirectory.Management.ADUser'
            }   
            $criados_ult_30min.DistinguishedName | Should -Not throw
            
        }
    }
    It 'should throw if object class is not "computer' {
        Mock Get-ADUser {
            New-MockObject -Type 'Microsoft.ActiveDirectory.Management.ADUser'
        }
    }
}