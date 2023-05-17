function Enable-NonAdminPrinterInstall {
    param (
        [string[]]
        $ComputerName
    )
    foreach ($comp in $ComputerName) {
    # Enable WinRM
    Start-Process -FilePath PsExec.exe -ArgumentList -s -nobanner \\$Comp /accepteula cmd /c "c:\windows\system32\winrm.cmd quickconfig -quiet" | Out-Null
    # Disable the Admin Req.
    Invoke-Command -ComputerName $Comp -ScriptBlock {Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name RestrictDriverInstallationToAdministrators -Value 0 }
    # I'm not yet sure if a reboot is required at this point, or if the drivers can just be installed now.
    # Set the value back to what MS recommends.
    Invoke-Command -ComputerName $Comp -ScriptBlock {Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name RestrictDriverInstallationToAdministrators -Value 1 }
    # Quality Check, of the RegKey value.
    Invoke-Command -ComputerName $Comp {Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name RestrictDriverInstallationToAdministrators }
    }#foreach
}