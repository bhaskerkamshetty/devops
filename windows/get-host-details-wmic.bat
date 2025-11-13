@ECHO OFF
rem #Author: Bhasker Kamshetty
rem #Description: This script collects hostname, username, serial#, mac address & stores data in Details.txt
rem #Date: 20th February 2024

rem #Appends Hostname
hostname >> Details.log

rem #Appends Username
whoami >> Details.log

rem #Appends Serial Number
for /f "tokens=2 delims==" %%a in ('wmic bios get serialnumber /value') do set "serialnumber=%%a"
echo %serialnumber% >> Details.log

rem #Appends MAC Address
SETLOCAL enabledelayedexpansion
FOR /f "delims=" %%a IN ('getmac /v ^|find /i "Ethernet"') DO (
 FOR %%b IN (%%a) DO (
  SET element=%%b
  IF "!element:~2,1!!element:~5,1!!element:~8,1!"=="---" set mac=%%b
 )
)
ECHO %mac% >> Details.log
GOTO :EOF
