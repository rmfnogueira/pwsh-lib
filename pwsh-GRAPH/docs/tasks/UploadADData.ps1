$actions = (New-ScheduledTaskAction -Execute 'UploadADData')
$trigger = New-ScheduledTaskTrigger -Daily -At '11:00 PM'
$principal = New-ScheduledTaskPrincipal -UserId 'domain\service-account' -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -WakeToRun
$task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger -Settings $settings