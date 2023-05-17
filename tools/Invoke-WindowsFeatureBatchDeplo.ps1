function Invoke-WindowsFeatureBatchDeployment {
    param (
        [parameter(mandatory)]
        [string[]] $computerNames,
        [parameter(mandatory)]
        [string] $ConfigurationFilepath
    )

    # Deploy the features on multiple computers simultaneously.
    $jobs = @()
    foreach ($computerName in $computerNames) {
        $jobs += Start-Job -Command {
            Install-WindowsFeature -ConfigurationFilePath $using:ConfigurationFilepath -ComputerName $using:computerName -Restart
        }
    }

    Receive-Job -Job $jobs -Wait | Select-Object Success, RestartNeeded, exitCode, FeatureResult
}