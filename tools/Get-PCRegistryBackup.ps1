function Get-PCRegistryBackup {
    param (
        $ComputerName
    )
    <#
    .SYNOPSIS
    
    .DESCRIPTION
    
    .NOTES
    
    .EXAMPLE

    .EXAMPLE
    
    .EXAMPLE
    #>

    #Backup Registry for given computername

    #HKLM\SOFTWARE\Microsoft\Windows NT\ CurrentVersion\ProfileList 
    #path to user profile 
    #Remove corrupted windows profile
    $objUser = New-Object System.Security.Principal.NTAccount(Read-Host -Prompt "Enter Username")
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    #$strSID.Value
    Rename-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\$($strSID.Value)" -NewName "$($strSID.Value).old"

}#Get-PCRegistryBackup