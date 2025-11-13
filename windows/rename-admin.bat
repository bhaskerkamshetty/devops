@ECHO OFF
rem #Author: Bhasker Kamshetty
rem #Description: This script changes hostname, renames administrator, enables administrator, sets password to administrator, deletes initial user
rem #Date: 20th February 2024

rem #To set custom hostname
set /p hostname=Enter Hostname: 
wmic computersystem where name="%computername%" call rename name="DESKTOP-%hostname%"

rem #To set serial number as hostname followed by PREDEFINED text
setlocal
for /f "tokens=2 delims==" %%a in ('wmic computersystem get name /value') do set "computername=%%a"
for /f "tokens=2 delims==" %%a in ('wmic bios get serialnumber /value') do set "serialnumber=%%a"
set "serialnumber=%serialnumber: =%"
echo Renaming computer from %computername% to %serialnumber%
wmic computersystem where name="%computername%" call rename name="PREDEFINED-%serialnumber%"
endlocal

rem #To set last 4 characters of serial number as hostname followed by PREDEFINED text
setlocal
for /f "tokens=2 delims==" %%a in ('wmic computersystem get name /value') do set "computername=%%a"
for /f "tokens=2 delims==" %%a in ('wmic bios get serialnumber /value') do set "serialnumber=%%a"
set "serialnumber=%serialnumber: =%" 
set "short_serial=%serialnumber:~-4%" 
wmic computersystem where name="%computername%" call rename name="PREDEFINED-%short_serial%"
endlocal

rem #PowerShell Command to rename Administrator
Rename-LocalUser -Name "Administrator" -NewName "NEWUSERNAME"
rem #WMIC Command to rename Administrator
wmic useraccount where name='Administrator' rename 'NEWUSERNAME'
net user NEWUSERNAME /active:yes
net user NEWUSERNAME PASSWORD
net user INITIALUSERNAME /delete
shutdown.exe /r /t 00


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

