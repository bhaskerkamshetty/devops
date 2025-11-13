#PowerShell Script to Add Domain
$domain = "DOMAIN.COM" # Replace with your actual domain
$username = "DOMAIN-ADMIN" # Replace with a user account that has domain join permissions
$password = "PASSWORD" # Replace with the actual password
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
Add-Computer -DomainName $domain -Credential $credential

#PowerShell Script to User to Domain
Add-LocalGroupMember -Group "Administrators" -Member "DOMAIN.COM\USERNAME"
