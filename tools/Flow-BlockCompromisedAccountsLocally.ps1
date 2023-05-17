# Block AD and Change Password on Compromised Accounts
Import-Module ActiveDirectory -UseWindowsPowerShell
Import-Module ExchangeOnline

Connect-exchangeOnline

$BlockedSenders = Get-BlockedSenderAddress

$SAMS=foreach ($sender in $BlockedSenders.SenderAddress) {$sender.SubString("",8)}

$Sams | %{Set-ADAccountPassword -Identity $_ -NewPassword (ConvertTo-SecureString -AsPlainText 'kqugsdbfiçugh8907653405876ljhvbqaoui7se56te084p67fvl.2qjl3yx4t5sxx01867423' -Force)}

$Sams | %{Set-ADUser -Enabled $false -Identity $_}

# Check if theres a new csv in folder
# if theres a new csv, import and take action on specified accounts

# Used sample
Import-Csv "C:\accounts_blocked_sendmail\24-10-2022.csv" | Foreach-Object {
    Disable-ADAccount -Identity $_.SamAccountName
    Set-ADAccountPassword -Identity $user -NewPassword "New-RandomPassword"
}
