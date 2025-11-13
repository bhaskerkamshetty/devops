<#
.SYNOPSIS
    Collects essential system details (hostname, username, serial number, and MAC address).
.DESCRIPTION
    This script retrieves system information using PowerShell cmdlets and native commands
    and appends the data to a file named Details.log.
.NOTES
    Author: Converted by Bhasker Kamshetty
    Date: November 2025
#>

# Define the log file path
$LogFile = ".\Details.log"

# --- 1. Collect Hostname ---
# Uses the native 'hostname' command and captures its output
Write-Host "Collecting Hostname..."
$Hostname = hostname
$Hostname | Add-Content -Path $LogFile

# --- 2. Collect Username ---
# Gets the current user's identity, and selects only the User property
Write-Host "Collecting Username..."
$Username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Username | Add-Content -Path $LogFile

# --- 3. Collect Serial Number ---
# Uses Get-WmiObject (or Get-CimInstance) to query the BIOS for the SerialNumber
Write-Host "Collecting Serial Number..."
$SerialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber
# Using Get-CimInstance is the modern, preferred way:
# $SerialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$SerialNumber | Add-Content -Path $LogFile

# --- 4. Collect MAC Address ---
# Gets network adapters, filters for the first physical adapter with a MAC address,
# and selects the MAC address property (Address)
Write-Host "Collecting MAC Address..."
$MacAddress = Get-NetAdapter -Physical |
              Where-Object {$_.MacAddress -ne $null -and $_.Status -eq 'Up'} |
              Select-Object -ExpandProperty MacAddress -First 1

# If no active physical MAC is found, fall back to the first non-loopback one
if (-not $MacAddress) {
    $MacAddress = Get-NetAdapter |
                  Where-Object {$_.Name -notlike '*Loopback*'} |
                  Select-Object -ExpandProperty MacAddress -First 1
}

$MacAddress | Add-Content -Path $LogFile

Write-Host "System details collected and appended to $LogFile"
