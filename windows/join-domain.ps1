# ==========================================
# Self-Elevation Block (Run as Administrator)
# ==========================================
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdministrator) {
    Write-Host "Requesting elevated permissions..." -ForegroundColor Yellow
    
    # Re-launch the script with elevated rights
    $processArgs = @{
        FilePath     = "powershell.exe"
        ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        Verb         = "RunAs"
    }
    Start-Process @processArgs
    Exit
}

# ==========================================
# Domain Join & Group Member Configuration
# ==========================================
$domain = "DOMAIN.COM"                 # Replace with your actual domain
$username = "DOMAIN\DOMAIN-ADMIN"       # Replace with admin account (format: DOMAIN\Admin or user@domain.com)
$password = "PASSWORD"                 # Replace with your actual password
$userToAdd = "DOMAIN\USERNAME"         # User/group to add to local Administrators (format: DOMAIN\User)

try {
    # 1. Create secure credentials
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

    # 2. Join Computer to Domain
    Write-Host "Joining computer to domain '$domain'..." -ForegroundColor Cyan
    Add-Computer -DomainName $domain -Credential $credential -ErrorAction Stop
    Write-Host "Successfully joined domain '$domain'." -ForegroundColor Green

    # 3. Add Domain User to Local Administrators Group
    Write-Host "Adding '$userToAdd' to local Administrators group..." -ForegroundColor Cyan
    Add-LocalGroupMember -Group "Administrators" -Member $userToAdd -ErrorAction Stop
    Write-Host "Successfully added '$userToAdd' to local Administrators." -ForegroundColor Green

    # 4. Optional: Prompt to restart (domain join requires a restart to take effect)
    Write-Host "`nA restart is required to complete the domain join." -ForegroundColor Yellow
    $restart = Read-Host "Do you want to restart now? (Y/N)"
    if ($restart -eq 'Y' -or $restart -eq 'y') {
        Restart-Computer -Force
    }
}
catch {
    Write-Error "An error occurred: $_"
    Read-Host "Press Enter to exit..."
}
