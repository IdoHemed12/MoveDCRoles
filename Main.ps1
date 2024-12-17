# Interactive FSMO Roles Transfer Script
# Author: [Ido Hemed]
# Version: 1.5

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "You must run this script as Administrator!" -ForegroundColor Red
    exit
}

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "Active Directory Module is not available. Please install RSAT and try again."
    exit
}
Import-Module ActiveDirectory

function Get-DomainControllers {
    try {
        $DCs = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName
        return $DCs
    }
    catch {
        Write-Error "Unable to retrieve Domain Controllers. Check your connection and permissions."
        exit
    }
}

function Get-FSMORoles {
    try {
        $Roles = @{
            "SchemaMaster"          = (Get-ADForest).SchemaMaster
            "DomainNamingMaster"    = (Get-ADForest).DomainNamingMaster
            "PDCEmulator"           = (Get-ADDomain).PDCEmulator
            "RIDMaster"             = (Get-ADDomain).RIDMaster
            "InfrastructureMaster"  = (Get-ADDomain).InfrastructureMaster
        }

        Write-Host "`nCurrent FSMO Role Holders:" -ForegroundColor Cyan
        foreach ($Role in $Roles.Keys) {
            Write-Host "$Role: $($Roles[$Role])" -ForegroundColor Yellow
        }

        return $Roles
    }
    catch {
        Write-Error "An error occurred while fetching FSMO roles."
        exit
    }
}

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

function Transfer-FSMORoles {
    param (
        [string]$Role,
        [string]$TargetDC
    )

    try {
        switch ($Role) {
            "SchemaMaster" {
                Write-Host "Transferring Schema Master Role..." -ForegroundColor Cyan
                Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole SchemaMaster -Confirm:$false
            }
            "DomainNamingMaster" {
                Write-Host "Transferring Domain Naming Master Role..." -ForegroundColor Cyan
                Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole DomainNamingMaster -Confirm:$false
            }
            "PDCEmulator" {
                Write-Host "Transferring PDC Emulator Role..." -ForegroundColor Cyan
                Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole PDCEmulator -Confirm:$false
            }
            "RIDMaster" {
                Write-Host "Transferring RID Master Role..." -ForegroundColor Cyan
                Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole RIDMaster -Confirm:$false
            }
            "InfrastructureMaster" {
                Write-Host "Transferring Infrastructure Master Role..." -ForegroundColor Cyan
                Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole InfrastructureMaster -Confirm:$false
            }
            "All" {
                Write-Host "Transferring All FSMO Roles..." -ForegroundColor Green
                Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC `
                    -OperationMasterRole SchemaMaster, DomainNamingMaster, PDCEmulator, RIDMaster, InfrastructureMaster `
                    -Confirm:$false
            }
            default {
                Write-Host "Invalid FSMO Role!" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Error "An error occurred while transferring the role: $_"
    }
}

Write-Host "Welcome to the FSMO Role Transfer Script!" -ForegroundColor Green

$TargetDC = Select-TargetDC
Write-Host "`nYou selected target Domain Controller: $TargetDC" -ForegroundColor Cyan

$Roles = Get-FSMORoles

do {
    $SelectedRole = Select-FSMORoles -Roles $Roles -TargetDC $TargetDC

    if ($SelectedRole -eq "All") {
        Transfer-FSMORoles -Role "All" -TargetDC $TargetDC
    }
    elseif ($SelectedRole) {
        Transfer-FSMORoles -Role $SelectedRole -TargetDC $TargetDC
    }
    elseif ($SelectedRole -eq $null) {
        Write-Host "Invalid choice or no roles available to transfer." -ForegroundColor Red
    }
    else {
        Write-Host "Exiting script. Goodbye!" -ForegroundColor Cyan
        exit
    }

    $Roles = Get-FSMORoles
    Write-Host "`nOperation Completed!" -ForegroundColor Green
    $continue = Read-Host "Do you want to transfer more roles? (Y/N)"
} while ($continue -match "^(Y|y)")

Write-Host "Thank you for using the FSMO Transfer Script!" -ForegroundColor Cyan
