$Date               = (Get-Date).AddMinutes(15)
$Interval           = 15
$RepetitionInterval = (New-TimeSpan -Minutes $Interval)
$RepetitionDuration = ([TimeSpan]::MaxValue)
$Trigger            = (New-JobTrigger -Once -At $Date -RepetitionInterval $RepetitionInterval -RepetitionDuration $RepetitionDuration) 
# $ScriptBlock        = {Get-LatestCreatedObjects | Invoke-ADTasks}
$FilePath           = ""
$Option             = (New-ScheduledJobOption -WakeToRun -RunElevated)

$params = @{
    Name        = ' '
    # ScriptBlock = $ScriptBlock
    FilePath    = $FilePath
    Trigger     = $Trigger
    ScheduledJobOption = $Option
}

Register-ScheduledJob @params