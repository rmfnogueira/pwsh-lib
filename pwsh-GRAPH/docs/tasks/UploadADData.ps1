$actions = (New-ScheduledTaskAction -Execute 'C:\dev\pwsh-edu-graph\src\private\Scripts\UploadDadosAD.ps1')
$trigger = New-ScheduledTaskTrigger -Daily -At '11:00 PM'
$principal = New-ScheduledTaskPrincipal -UserId 'edu\sysadmin' -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -WakeToRun
$task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger -Settings $settings

l