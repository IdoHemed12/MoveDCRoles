function Select-FSMORoles {
    param (
        [hashtable]$Roles,
        [string]$TargetDC
    )

    Write-Host "`nWhich FSMO roles would you like to transfer to $TargetDC?" -ForegroundColor Cyan

    $Menu = @{}
    $Option = 1
    foreach ($Role in $Roles.Keys) {
        if ($Roles[$Role] -ne $TargetDC) {
            $Menu[$Option] = $Role
            Write-Host "$Option. $Role" -ForegroundColor Yellow
            $Option++
        }
    }

    if ($Menu.Count -gt 0) {
        $Menu[$Option] = "All"
        Write-Host "$Option. Move All FSMO Roles" -ForegroundColor Green
    }

    Write-Host "0. Exit" -ForegroundColor Red

    $choice = Read-Host "Enter your choice (number)"
    return $Menu[$choice]
}
