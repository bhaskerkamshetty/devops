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

:: Lock root working directory
set "ROOT_DIR=%~dp0"
cd /d "%ROOT_DIR%"

:: Generate safe ANSI color codes dynamically
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "CYAN=%ESC%[96m"
set "RESET=%ESC%[0m"

echo ===================================================
echo       Silent Software Batch Installer
echo ===================================================
echo.

:: ============================================================================
:: 2. CONFIGURED SOFTWARE LIST
:: ============================================================================
set "TOTAL=0"

:: --- App 1: Oracle JRE ---
set /a TOTAL+=1
set "NAME[!TOTAL!]=Oracle JRE 8u491"
set "PATH[!TOTAL!]=B:\Apps\Softwares\jre-8u491-windows-x64.exe"
set "ARGS[!TOTAL!]=/s"

:: --- App 2: 7-Zip ---
set /a TOTAL+=1
set "NAME[!TOTAL!]=7-Zip 64-bit"
set "PATH[!TOTAL!]=B:\Apps\Softwares\7z2602-x64.exe"
set "ARGS[!TOTAL!]=/S"

:: --- App 3: Microsoft 365 Batch Script ---
set /a TOTAL+=1
set "NAME[!TOTAL!]=Microsoft 365"
set "PATH[!TOTAL!]=B:\Apps\Softwares\M365\install_m365.bat"
set "ARGS[!TOTAL!]="

:: ============================================================================
:: 3. INITIALIZE SUMMARY COUNTERS
:: ============================================================================
set "COUNT_SUCCESS=0"
set "COUNT_FAILED=0"
set "COUNT_NOTFOUND=0"

:: ============================================================================
:: 4. EXECUTION LOOP
:: ============================================================================
for /L %%i in (1, 1, %TOTAL%) do (
    set "CURRENT_INDEX=%%i"
    set "CURRENT_NAME=!NAME[%%i]!"
    set "CURRENT_PATH=!PATH[%%i]!"
    set "CURRENT_ARGS=!ARGS[%%i]!"
    
    call :ExecuteInstall
)

:: ============================================================================
:: 5. SUMMARY REPORT
:: ============================================================================
set /a TOTAL_FAILED=COUNT_FAILED+COUNT_NOTFOUND

echo ===================================================
echo                 INSTALLATION SUMMARY               
echo ===================================================
echo Total Configured Targets : %CYAN%!TOTAL!%RESET%
echo Successfully Installed   : %GREEN%!COUNT_SUCCESS!%RESET%
echo Failed Installations     : %RED%!COUNT_FAILED!%RESET%
echo Missing File Paths       : %RED%!COUNT_NOTFOUND!%RESET%
echo ===================================================

if !TOTAL_FAILED! equ 0 (
    echo %GREEN%All packages installed successfully!%RESET%
) else (
    echo %RED%Some installations encountered errors. Check logs above.%RESET%
)
echo.
pause
exit /b

:: ============================================================================
:: 6. INSTALLATION SUBROUTINE
:: ============================================================================
:ExecuteInstall
echo [!CURRENT_INDEX!/%TOTAL%] Processing !CURRENT_NAME!...

if not exist "!CURRENT_PATH!" (
    echo       Result: %RED%[FAILED - FILE PATH DOES NOT EXIST]%RESET%
    echo       Target: "!CURRENT_PATH!"
    set /a COUNT_NOTFOUND+=1
    echo.
    exit /b 0
)

echo       Installing...

set "EXT=!CURRENT_PATH:~-4!"

:: Handle batch files: extract folder and change directory before running
if /i "!EXT!"==".bat" (
    for %%F in ("!CURRENT_PATH!") do cd /d "%%~dpF"
    cmd.exe /c call "!CURRENT_PATH!" !CURRENT_ARGS!
    cd /d "%ROOT_DIR%"
) else if /i "!EXT!"==".cmd" (
    for %%F in ("!CURRENT_PATH!") do cd /d "%%~dpF"
    cmd.exe /c call "!CURRENT_PATH!" !CURRENT_ARGS!
    cd /d "%ROOT_DIR%"
) else if /i "!EXT!"==".msi" (
    msiexec /i "!CURRENT_PATH!" !CURRENT_ARGS!
) else (
    start /wait "" "!CURRENT_PATH!" !CURRENT_ARGS!
)

set "RUN_CODE=!errorlevel!"

if !RUN_CODE! equ 0 (
    echo       Result: %GREEN%[SUCCESS]%RESET%
    set /a COUNT_SUCCESS+=1
) else if !RUN_CODE! equ 3010 (
    echo       Result: %GREEN%[SUCCESS - REBOOT REQUIRED]%RESET%
    set /a COUNT_SUCCESS+=1
) else (
    echo       Result: %RED%[FAILED - Exit Code: !RUN_CODE!]%RESET%
    set /a COUNT_FAILED+=1
)

echo.
exit /b 0
