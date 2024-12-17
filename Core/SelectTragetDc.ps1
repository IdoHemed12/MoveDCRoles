function Select-TargetDC {
    $DCs = Get-DomainControllers
    Write-Host "`nAvailable Domain Controllers:" -ForegroundColor Cyan
    $Menu = @{}
    $Option = 1

    foreach ($DC in $DCs) {
        $Menu[$Option] = $DC
        Write-Host "$Option. $DC" -ForegroundColor Yellow
        $Option++
    }

    $choice = Read-Host "Select the target Domain Controller by entering its number"
    if ($Menu.ContainsKey([int]$choice)) {
        return $Menu[[int]$choice]
    }
    else {
        Write-Host "Invalid choice. Please try again." -ForegroundColor Red
        return Select-TargetDC
    }
}
