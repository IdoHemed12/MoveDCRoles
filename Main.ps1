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

$ErrorLoadingCore = Write-Host "Error Accord with loading on of the Core Funtions, Please Review the Core Directory" -ForegroundColor Red
try{
. "$PSScriptRoot\core\GetDomainControllers.ps1"
}
catch{
$ErrorLoadingCore
}

try{
. "$PSScriptRoot\core\GetDomainControllers.ps1"
}
catch{
$ErrorLoadingCore
}




do {
    Write-Host @"
 ___ ___   ___   __ __    ___      ___      __      ____   ___   _        ___  _____
|   |   | /   \ |  |  |  /  _]    |   \    /  ]    |    \ /   \ | |      /  _]/ ___/
| _   _ ||     ||  |  | /  [_     |    \  /  /     |  D  )     || |     /  [_(   \_ 
|  \_/  ||  O  ||  |  ||    _]    |  D  |/  /      |    /|  O  || |___ |    _]\__  |
|   |   ||     ||  :  ||   [_     |     /   \_     |    \|     ||     ||   [_ /  \ |
|   |   ||     | \   / |     |    |     \     |    |  .  \     ||     ||     |\    |
|___|___| \___/   \_/  |_____|    |_____|\____|    |__|\_|\___/ |_____||_____| \___|
                                                                                    
"@ -ForegroundColor Cyan

    $Exit = Read-Host "Do you want to transfer more roles? (Y/N)"
} while ($Exit -notmatch "^n|N")

Write-Host "Thank you for using the FSMO Transfer Script!" -ForegroundColor Cyan
