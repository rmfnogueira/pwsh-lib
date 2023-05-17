function LinkGpobyState ([string]$ou_path, [string[]]$ou_names ) {
    $ous = Get-ADOrganizationalUnit -Filter * -SearchBase $ou_path -SearchScope OneLevel
    foreach ($ou in $ous) {
        switch -regex ($ou.State) {
            'text_to_match' { New-GPLink -Name $ou_names[0] -Target $ou.distinguishedName }
            'text_to_match' { New-GPLink -Name $ou_names[1] -Target $ou.distinguishedName }
            Default {}
        }
    }
}




