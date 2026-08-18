# ==========================================
# Self-Elevation Block (Run as Administrator)
# ==========================================
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Administrator rights required. Requesting elevation..."
    
    # Relaunch script with elevated privileges
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "powershell.exe"
    
    if ($PSCommandPath) {
        $processInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        # Fallback if running directly from console/ISE
        $processInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"$($MyInvocation.MyCommand.Definition)`""
    }
    
    $processInfo.Verb = "runas"
    
    try {
        [System.Diagnostics.Process]::Start($processInfo) | Out-Null
        exit
    } catch {
        Write-Error "Failed to elevate: User cancelled UAC or lacks administrative credentials."
        exit 1
    }
}

# ==========================================
# 1. Computer Rename
# ==========================================
$Prefix = "PREDEFINEDTEXT-"
$SerialNumber = (Get-CimInstance -ClassName Win32_Bios).SerialNumber

if ($SerialNumber.Trim().Length -ge 4) {
    $ShortSerial = $SerialNumber.Trim().Substring($SerialNumber.Trim().Length - 4)
    $NewHostname = "$Prefix$ShortSerial"
    
    Write-Host "Current Hostname: $((Get-CimInstance -ClassName Win32_ComputerSystem).Name)" -ForegroundColor Cyan
    Write-Host "Target Hostname:  $NewHostname" -ForegroundColor Cyan
    
    Rename-Computer -NewName $NewHostname -Force -PassThru
} else {
    Write-Warning "Serial number is shorter than 4 characters. Skipping rename."
}

# ==========================================
# 2. Local Account Management
# ==========================================
$NewLocalAdminName = "Admin"
$LocalAdminPassword = "REPLACE_WITH_STRONG_PASSWORD" # Secure local password
$UserToDelete = "INITIALUSERNAME"

# Rename and activate built-in Administrator
$builtinAdmin = Get-LocalUser | Where-Object { $_.SID -like "*-500" }
if ($builtinAdmin) {
    Rename-LocalUser -Name $builtinAdmin.Name -NewName $NewLocalAdminName -ErrorAction SilentlyContinue
    Enable-LocalUser -Name $NewLocalAdminName
    Set-LocalUser -Name $NewLocalAdminName -Password (ConvertTo-SecureString $LocalAdminPassword -AsPlainText -Force)
    Write-Host "Local Administrator configured as '$NewLocalAdminName'." -ForegroundColor Green
}

# Remove initial setup account
if (Get-LocalUser -Name $UserToDelete -ErrorAction SilentlyContinue) {
    Remove-LocalUser -Name $UserToDelete
    Write-Host "Removed temporary user: $UserToDelete" -ForegroundColor Green
}

# ==========================================
# 3. Final Restart
# ==========================================
Write-Host "Operations complete. Restarting computer in 0 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 0
Restart-Computer -Force
