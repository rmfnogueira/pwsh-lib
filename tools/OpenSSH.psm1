function Get-OpenSSH {
    param ()
    $url = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest/'
    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect = $false
    $response = $request.GetResponse()
    $source = $([String]$response.GetResponseHeader("Location")).Replace('tag', 'download') + '/OpenSSH-Win64.zip'
    $webClient = [System.Net.WebClient]::new()
    $webClient.DownloadFile($source, (Get-Location).Path + '\OpenSSH-Win64.zip')
}

function Install-OpenSSH {
    param()

    # Extract the ZIP to a temporary location
    Expand-Archive -Path .\OpenSSH-Win64.zip -DestinationPath ($env:temp) -Force
    # Move the extracted ZIP contents from the temporary location to C:\Program Files\OpenSSH\
    Move-Item "$($env:temp)\OpenSSH-Win64" -Destination "C:\Program Files\OpenSSH\" -Force
    # Unblock the files in C:\Program Files\OpenSSH\
    Get-ChildItem -Path "C:\Program Files\OpenSSH\" | Unblock-File
    & 'C:\Program Files\OpenSSH\install-sshd.ps1'
    ## changes the sshd service's startup type from manual to automatic.
    Set-Service sshd -StartupType Automatic
    ## starts the sshd service.
    Start-Service sshd
    New-NetFirewallRule -Name sshd -DisplayName 'Allow SSH' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}   