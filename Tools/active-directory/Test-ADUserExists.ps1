function Test-ADUserAttributes {
    $InputObject | ForEach-Object {
        $value = $_
        $filter = "(|"
        foreach ($attribute in $attributes) {
            $filter += "($attribute -eq '$value')"
        }
        $filter += ")"
        $users = Get-ADUser -Filter $filter -Properties $attributes

        if ($users) {
            Write-Host "The value '$value' is already in use for one of the following attributes:"
            foreach ($user in $users) {
                foreach ($attribute in $attributes) {
                    if ($user.($attribute) -eq $value) {
                        Write-Host " - '$attribute' for user '$($user.Name)'"
                    }
                }
            }
        }
        else {
            Write-Host "The value '$value' is not in use for any of the specified attributes."
        }
    
    
    }
}






