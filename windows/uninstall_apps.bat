@echo off
setlocal EnableDelayedExpansion

:: -----------------------------------------------------------------------------
:: 1. Self-Elevation Check (Run as Administrator)
:: -----------------------------------------------------------------------------
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c', '\"%~dpnx0\"' -Verb RunAs"
    exit /b
)

:: -----------------------------------------------------------------------------
:: 2. Setup ANSI Color Codes (Windows 10/11)
:: -----------------------------------------------------------------------------
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "YELLOW=%ESC%[93m"
set "RESET=%ESC%[0m"

title Software Uninstaller Suite
cls
echo ======================================================
echo           AUTOMATED SOFTWARE UNINSTALLER
echo ======================================================
echo.

:: -----------------------------------------------------------------------------
:: 3. Define Software Uninstall Routines
:: -----------------------------------------------------------------------------

:: --- Example 1: MSI-Based Software (Using Product GUID) ---
set "APP_NAME=Sample MSI Application"
echo Uninstalling %APP_NAME%...
msiexec.exe /x "{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}" /qn /norestart
call :CheckStatus "%APP_NAME%"


:: --- Example 2: EXE Uninstaller (e.g., Inno Setup / NSIS / Vendor EXE) ---
set "APP_NAME=Sample EXE Application"
echo Uninstalling %APP_NAME%...
if exist "C:\Program Files\SampleApp\uninstall.exe" (
    start /wait "" "C:\Program Files\SampleApp\uninstall.exe" /S
    call :CheckStatus "%APP_NAME%"
) else (
    call :NotFound "%APP_NAME%"
)


:: --- Example 3: Winget Uninstaller ---
set "APP_NAME=7-Zip"
echo Uninstalling %APP_NAME% via Winget...
winget uninstall --id 7zip.7zip --silent --accept-source-agreements >nul 2>&1
call :CheckStatus "%APP_NAME%"

echo.
echo ======================================================
echo All uninstallation tasks completed.
echo ======================================================
echo.
pause
exit /b

:: -----------------------------------------------------------------------------
:: 4. Status Check Subroutines
:: -----------------------------------------------------------------------------
:CheckStatus
if %ERRORLEVEL% EQU 0 (
    echo %GREEN%[SUCCESS]%RESET% %~1 was uninstalled successfully.
) else (
    echo %RED%[FAILED]%RESET% Failed to uninstall %~1 ^(Exit Code: %ERRORLEVEL%^).
)
echo.
exit /b

:NotFound
echo %YELLOW%[SKIPPED]%RESET% %~1 uninstaller was not found on this system.
echo.
exit /b
