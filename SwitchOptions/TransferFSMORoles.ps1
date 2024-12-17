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
