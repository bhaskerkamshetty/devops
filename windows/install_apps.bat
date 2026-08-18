@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: 1. AUTO-ELEVATE TO ADMINISTRATOR
:: ============================================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set working directory to script location
cd /d "%~dp0"

:: Set ANSI Color Codes
set "ESC="
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "YELLOW=%ESC%[93m"
set "RESET=%ESC%[0m"

echo ===================================================
echo       Silent Software Installer - Admin Mode
echo ===================================================
echo.

:: ============================================================================
:: 2. INSTALLATION TARGETS
:: ============================================================================

:: Target 1: MSI Installer
if exist "installer.msi" (
    <nul set /p="Installing MSI package... "
    msiexec /i "%~dp0installer.msi" /qn /norestart
    call :CheckStatus
) else (
    echo %YELLOW%[SKIPPED] installer.msi not found.%RESET%
)

:: Target 2: Inno Setup (.exe)
if exist "inno_setup.exe" (
    <nul set /p="Installing Inno Setup application... "
    start /wait "" "%~dp0inno_setup.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
    call :CheckStatus
) else (
    echo %YELLOW%[SKIPPED] inno_setup.exe not found.%RESET%
)

:: Target 3: NSIS Installer (.exe)
if exist "nsis_setup.exe" (
    <nul set /p="Installing NSIS application... "
    start /wait "" "%~dp0nsis_setup.exe" /S
    call :CheckStatus
) else (
    echo %YELLOW%[SKIPPED] nsis_setup.exe not found.%RESET%
)

:: Target 4: Winget Package (7-Zip)
<nul set /p="Installing 7-Zip via Winget... "
winget install --id 7zip.7zip --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
call :CheckStatus

:: Target 5: Winget Package (Google Chrome)
<nul set /p="Installing Google Chrome via Winget... "
winget install --id Google.Chrome --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
call :CheckStatus

echo.
echo ===================================================
echo       All installations finished!
echo ===================================================
echo.
pause
exit /b

:: ============================================================================
:: 3. STATUS HELPER FUNCTION
:: ============================================================================
:CheckStatus
:: Common success codes: 0 = OK, 3010 = Success (Reboot required)
if %errorlevel% equ 0 (
    echo %GREEN%[SUCCESS]%RESET%
) else if %errorlevel% equ 3010 (
    echo %GREEN%[SUCCESS - REBOOT REQUIRED]%RESET%
) else (
    echo %RED%[FAILED] (Error Code: %errorlevel%)%RESET%
)
exit /b
