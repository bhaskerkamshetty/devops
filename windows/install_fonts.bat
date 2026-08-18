<# :
@echo off
setlocal

:: Auto-Elevate to Administrator Privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-Process -FilePath '%comspec%' -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo Running with Administrator privileges.
echo Overwriting and installing all .ttf, .otf, and .ttc fonts...
echo ----------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$scriptContent = [System.IO.File]::ReadAllText('%~f0');" ^
    "$sourcePath = '%~dp0';" ^
    "Invoke-Command -ScriptBlock ([scriptblock]::Create($scriptContent)) -ArgumentList $sourcePath"

echo ----------------------------------------------------------------
echo All fonts successfully replaced and registered!
pause
exit /b
#>

param($sourceDir)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class FontInstaller {
    [DllImport("gdi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int AddFontResource(string lpszFilename);

    [DllImport("gdi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int RemoveFontResource(string lpszFilename);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    public const uint WM_FONTCHANGE = 0x001D;
    public static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);

    public static void Notify() {
        SendMessage(HWND_BROADCAST, WM_FONTCHANGE, IntPtr.Zero, IntPtr.Zero);
    }
}
"@

$winFonts = [System.Environment]::GetFolderPath('Fonts')
$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'

if (-not $sourceDir) { $sourceDir = (Get-Location).Path }

Get-ChildItem -Path $sourceDir -Include *.ttf, *.otf, *.ttc -Recurse | ForEach-Object {
    $destPath = Join-Path $winFonts $_.Name

    # If file exists and is locked in memory, unload it via GDI first
    if (Test-Path $destPath) {
        [FontInstaller]::RemoveFontResource($destPath) | Out-Null
    }

    try {
        Copy-Item -Path $_.FullName -Destination $destPath -Force -ErrorAction Stop
        Write-Host ("[Installed]   " + $_.Name) -ForegroundColor Green
    }
    catch {
        # Fallback if a persistent background process holds a hard handle
        Write-Host ("[Locked/Skip] " + $_.Name + " - active in another app") -ForegroundColor Yellow
    }

    $type = if ($_.Extension -eq '.otf') { '(OpenType)' } else { '(TrueType)' }
    $regName = "$($_.BaseName) $type"
    Set-ItemProperty -Path $regPath -Name $regName -Value $_.Name -Force -ErrorAction SilentlyContinue | Out-Null
    [FontInstaller]::AddFontResource($destPath) | Out-Null
}

[FontInstaller]::Notify()
