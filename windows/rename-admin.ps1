#PowerShell Commands
$Prefix = "PREDEFINEDTEXT-"
$SerialNumber = (Get-CimInstance -ClassName Win32_Bios).SerialNumber
$ShortSerial = $SerialNumber.Trim().Substring($SerialNumber.Trim().Length - 4)
$NewHostname = "$Prefix$ShortSerial"
Write-Host "Current Hostname: $((Get-CimInstance -ClassName Win32_ComputerSystem).Name)"
Write-Host "New Hostname will be: $NewHostname"
Rename-Computer -NewName $NewHostname -Force -PassThru

#PowerShell command to rename Administrator
Rename-LocalUser -Name "Administrator" -NewName "Admin"
net user Admin /active:yes
net user Admin PASSWORD
net user INITIALUSERNAME /delete

#Restart Computer
Restart-Computer -Force

$domain = "DOMAIN.COM" # Replace with your actual domain
$username = "DOMAIN-ADMIN" # Replace with a user account that has domain join permissions
$password = "PASSWORD" # Replace with the actual password
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
Add-Computer -DomainName $domain -Credential $credential
Add-LocalGroupMember -Group "Administrators" -Member "DOMAIN.COM\DOMAIN-ADMIN"
