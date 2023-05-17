### Manutenção Moodle EDU
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $hoje = (Get-Date -Format 'ddMMyy'),

    [Parameter()]
    [ValidateScript(
        {Test-Path '/var/www/html/'},
        ErrorMessage = "{0} could not find web dir path",
        break
    )]
    [string]
    $dir_web = '/var/www/html/',

    [Parameter()]
    [ValidateScript(
        {Test-Path '/var/moodledata'},
        ErrorMessage = "{0} could not find moodle data directory path",
        break
    )]
    [string]
    $dir_data = '/var/moodledata',

    $dir_data_backup = "/root/moodle_backup/web/$today",
    $dir_web_backup = "/root/moodle_backup/moodledata/$today"
)

# TODO: Add await to each function so commands run as workflow, with exception handling (break on any)
$sites_moodle = gci $dir_web

function Backup-MoodleWeb {
        try {
            mkdir $dir_web_backup
        }
        catch {
            return "Could Not Create backup directories. Please check your paths"
            break
        }
        cp -fr "$dir_web/*" "$dir_web_backup"
}

function Backup-MoodleData {
    try {
        mkdir $dir_web_backup
    }
    catch {
        return "Could Not Create backup directories. Please check your paths"
        break
    }
    cp -fr "$dir_data/*" "$dir_data_backup"
}

function Enable-MoodleMaintenanceMode {
    foreach ($dir in $sites_moodle.FullName) {
        Set-Location $dir
        sudo -u apache /usr/bin/php .admin/cli/maintenance.php --enable
    }
}

function Disable-MoodleMaintenanceMode {
    foreach ($dir in $sites_moodle.FullName) {
        Set-Location $dir
        sudo -u apache /usr/bin/php .admin/cli/maintenance.php --disable
    }
}

function Update-SourceCode {
    foreach ($dir in $sites_moodle.FullName) {
        Set-Location $dir
        try {
            git pull
        } catch {
            $_
        }
    }
}

function Update-MoodleInstances {
    # upgrade, mantendo a mesma versão stable
    foreach ($dir in $sites_moodle.FullName) {
        try {
            Set-Location $sites_moodle.FullName
            sudo -u apache /usr/bin/php ./admin/cli/upgrade.php; 
        }
        catch {
            $_
        }
    }
}
