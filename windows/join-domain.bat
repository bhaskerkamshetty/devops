@ECHO OFF
rem #Author: Bhasker Kamshetty
rem #Description: This script joins windows machine into a domain 
rem #Date: 20th February 2024

wmic computersystem where name="%computername%" call joindomainorworkgroup fjoinoptions=3 name="DOMAIN.COM" username="DOMAIN.COM\USERNAME" Password="PASSWORD"
shutdown.exe /r /t 00
