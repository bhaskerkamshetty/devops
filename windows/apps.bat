@ECHO OFF
rem #Author: Bhasker Kamshetty
rem #Description: This script installs powershell & powertoys
rem #Date: 23rd September 2024

rem #Installs PowerShell
winget install --id Microsoft.PowerShell --source winget

rem #Installs PowerToys
winget install --id Microsoft.PowerToys --source winget

rem #Installs Git
winget install --id Git.Git -e --source winget
