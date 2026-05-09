# tmpcln.ps1 - This used to be a regular batch file but ported over to a PowerShell script 
# for additional functionality. Licensed under the BSD "new" license.
# 
# Copyright (C) 1992-2026 Charles McDonald.

# Check for Admin rights - required to clear System folders
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    Pause
    Exit
}

# The Explanatory Message
$msgTitle = "Windows 11 System Cleanup"
$msgBody = @"
This script will perform the following actions:
1. Stop the Windows Update Service (to clear cache).
2. Delete all files in C:\Windows\SoftwareDistribution (Windows Update leftovers).
3. Empty System Temp and User Temp folders.
4. Clear the Prefetch folder (cached application launch data).
5. Empty the Recycle Bin.

Do you want to proceed?
"@

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Starts the cleanup process."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Cancels the operation."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($msgTitle, $msgBody, $options, 0)

if ($result -eq 0) {
    Write-Host "`n[!] Starting Cleanup..." -ForegroundColor Cyan

    # 1. Stop Windows Update Service
    Write-Host "[*] Stopping Windows Update services..." -ForegroundColor Yellow
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Stop-Service -Name bits -Force -ErrorAction SilentlyContinue

    # 2. Clear SoftwareDistribution
    Write-Host "[*] Clearing SoftwareDistribution folder..." -ForegroundColor Yellow
    Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue

    # 3. Restart Windows Update Service
    Start-Service -Name wuauserv
    Start-Service -Name bits

    # 4. Clear Temp Folders
    Write-Host "[*] Cleaning Temporary files..." -ForegroundColor Yellow
    $tempPaths = @(
        "$env:TEMP\*",
        "C:\Windows\Temp\*",
        "C:\Windows\Prefetch\*"
    )

    foreach ($path in $tempPaths) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    }

    # 5. Empty Recycle Bin
    Write-Host "[*] Emptying Recycle Bin..." -ForegroundColor Yellow
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue

    Write-Host "`n[+] Cleanup Complete!" -ForegroundColor Green
}
else {
    Write-Host "`n[X] Operation cancelled by user." -ForegroundColor Red
}

Pause
