@ECHO OFF
rem #Author: Bhasker Kamshetty
rem #Description: This script extracts specific edition of windows os from wim or esd file 
rem #Date: 20th February 2024

echo Windows ISO Extractor
SET /P driveletter=Enter drive letter : 
SET /P filetype=Enter file type wim or esd : 
DISM /Get-WimInfo /WimFile:%driveletter%:\sources\install.%filetype%
SET /P index=Enter index number to extract : 
echo File is saved at "%homedrive%%homepath%\Desktop\install.%filetype%"
DISM /Export-Image /SourceImageFile:%driveletter%:\sources\install.%filetype% /SourceIndex:%index% /DestinationImageFile:"%homedrive%%homepath%\Desktop\install.%filetype%"
