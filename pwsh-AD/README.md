## PWSH-AD

> **Powershell ActiveDirectory custom module to automate and facilitate recurring tasks in a large enterprise environment.**

### **Provided functionality includes:**
- Moves AD objects automatically to target OU based on object's Name attribute.
- Conditionally adds objects to groups based on distinguishedName attribute.
- Generates new users logon (SamAccountName) using birthday and First and LastName (i.e.: TT111045 - TT111045@contoso.com ).
- Created custom users in bulk, based on template CSV.

> Tested with Windows Powershell 5.1, and is currently in production on two private domains.

> Using Poweshell 7.3 and importing the module with the option -UseWindowsPowershell does work with all commands.

### **Environment Setup**
- Scheduled Tasks running invoking Windows Powershell executable. (PS Version '5.1.0') 
- If using Powershell (7.0.0 +) can be used with -UseWindowsPowershell option on Import-Module command.
- Running in production on Windows Server 2019-2022.
- Running locally to avoid object serialization and deserialization, as it was causing some logging and exporting problems on these specific environments.
- Optionally can be run unnatended from a remote computer, and can be used with secret store/vault.


> If using scheduled jobs, below are some examples of a sample confguration.

### **Scheduled Job Creation**

```powershell
Register-ScheduledJob 
 -Name 'Set-ADUserLicense' 
 -ScriptBlock {Import-Module pwsh-AD; Set-EduUserLicense} 
 -Trigger (New-JobTrigger 
 -Once -At "15/03/2022 15:00pm" 
 -RepetitionInterval (New-TimeSpan -Minutes 15) 
 -RepetitionDuration ([TimeSpan]::MaxValue)) 
 -ScheduledJobOption (New-ScheduledJobOption 
 -WakeToRun -RunElevated 
 -DoNotAllowDemandStart 
 -HideInTaskScheduler 
 -RequireNetwork)
```

### **Update Scheduled Job Definition (using Job Id 5):**
```powershell
Get-ScheduledJob -Id 5 | 
Set-ScheduledJob -Name Test-ADComputerNaming  -ScriptBlock {
    Import-Module C:\dev\pwsh-edu\pwsh-edu.psm1;
    Test-ADComputerNaming
}
```
