<#
.SYNOPSIS
    Collects essential system details and appends them without leaving empty rows.
.DESCRIPTION
    Retrieves Hostname, Serial Number, MAC, CPU details, RAM, Disks, and GPU.
.NOTES
    Author: Converted by Bhasker Kamshetty
#>

# Define absolute export file path in the current execution folder
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }
$ExportFile = Join-Path $ScriptDir "SystemDetails.csv"

Write-Host "Collecting System Details..."

# --- 1. Collect Existing Non-Empty Lines & Calculate Row Count (#) ---
$ExistingCleanLines = @()
$Count = 1

if (Test-Path $ExportFile) {
    try {
        # Read file and filter out completely empty lines or whitespace-only lines
        $ExistingCleanLines = @(Get-Content -Path $ExportFile -Encoding UTF8 -ErrorAction Stop | Where-Object { $_.Trim() -ne "" })
        if ($ExistingCleanLines.Count -ge 1) {
            # Count excludes the header line
            $Count = $ExistingCleanLines.Count
        }
    } catch {
        $Count = 1
    }
}

# --- 2. Collect Hostname, Serial Number & MAC Address ---
$Hostname = $env:COMPUTERNAME
$SerialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

$MacAddress = (Get-NetAdapter -Physical | Where-Object { $_.MacAddress -ne $null -and $_.Status -eq 'Up' } | Select-Object -First 1).MacAddress
if (-not $MacAddress) {
    $MacAddress = (Get-NetAdapter | Where-Object { $_.Name -notlike '*Loopback*' } | Select-Object -First 1).MacAddress
}

# --- 3. Collect Processor Details (Sockets, Cores & Threads) ---
$CPU_Objects = @(Get-CimInstance -ClassName Win32_Processor)
$PhysicalCPUCount = $CPU_Objects.Count
$TotalCores = ($CPU_Objects | Measure-Object -Property NumberOfCores -Sum).Sum
$TotalThreads = ($CPU_Objects | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum

$CPU_Name = ($CPU_Objects[0].Name) -replace '\s+', ' '
$Processor = "$CPU_Name [$PhysicalCPUCount CPU(s), $TotalCores Cores, $TotalThreads Threads]"

# --- 4. Collect RAM Details (Consolidated) ---
$TotalRAM_Bytes = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory
$TotalRAM_GB = [math]::Round($TotalRAM_Bytes / 1GB)

$RamSticks = @(Get-CimInstance -ClassName Win32_PhysicalMemory)
$RamSlots = @()
$slotIndex = 1

foreach ($stick in $RamSticks) {
    $mfg   = if ($stick.Manufacturer) { $stick.Manufacturer.Trim() } else { "Unknown" }
    $size  = "{0}GB" -f [math]::Round($stick.Capacity / 1GB)
    $speed = if ($stick.ConfiguredClockSpeed) { "$($stick.ConfiguredClockSpeed)Mhz" } else { "$($stick.Speed)Mhz" }
    $RamSlots += "Slot${slotIndex} : $mfg $size @ $speed"
    $slotIndex++
}

$RAM = "Installed RAM: ${TotalRAM_GB}GB"
if ($RamSlots.Count -gt 0) {
    $RAM += " | " + ($RamSlots -join " | ")
}

# --- 5. Collect Non-USB Storage Disks (Full Manufacturer Capacity) ---
$Disks = @(Get-CimInstance -ClassName Win32_DiskDrive | Where-Object { 
    $_.InterfaceType -ne 'USB' -and 
    $_.MediaType -ne 'Removable Media' -and 
    $_.Model -notmatch 'USB'
})

$DiskList = @()
$diskIndex = 0

foreach ($disk in $Disks) {
    $rawBytes = $disk.Size
    if ($rawBytes -gt 0) {
        $decimalGB = [math]::Round($rawBytes / 1000000000, 2)
        $diskSize = "$decimalGB GB"
    } else {
        $diskSize = "Unknown Size"
    }
    
    $DiskList += "Disk${diskIndex}: $($disk.Model) ($diskSize)"
    $diskIndex++
}

$Disks_Details = if ($DiskList.Count -gt 0) { $DiskList -join " | " } else { "No Internal Disks Detected" }

# --- 6. Collect Graphic Card & VRAM ---
$GPUs = Get-CimInstance -ClassName Win32_VideoController
$GPU_Info = @()

foreach ($gpu in $GPUs) {
    $vramGB = [math]::Round($gpu.AdapterRAM / 1GB, 2)
    if ($vramGB -eq 0 -and $gpu.AdapterRAM -gt 0) {
        $vramMB = [math]::Round($gpu.AdapterRAM / 1MB, 2)
        $GPU_Info += "$($gpu.Name) ($vramMB MB VRAM)"
    } else {
        $GPU_Info += "$($gpu.Name) ($vramGB GB VRAM)"
    }
}
$GraphicCard = $GPU_Info -join " | "

# --- 7. Build the Output Object ---
$SystemInfo = [PSCustomObject]@{
    "#"             = $Count
    "Serial Number" = $SerialNumber
    "Hostname"      = $Hostname
    "MAC Address"   = $MacAddress
    "Processor"     = $Processor
    "RAM"           = $RAM
    "Storage" = $Disks_Details
    "Graphic Card"  = $GraphicCard
}

# --- 8. Clean Write & Append (Zero Blank Lines) ---
$WriteSuccess = $false
while (-not $WriteSuccess) {
    try {
        if ($ExistingCleanLines.Count -eq 0) {
            # First run: Generate CSV header and first row
            $SystemInfo | Export-Csv -Path $ExportFile -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
        } else {
            # Extract just the data row string
            $NewCsvRow = ($SystemInfo | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1) -join ""
            
            # Combine all non-empty lines with the new line
            $AllLines = $ExistingCleanLines + $NewCsvRow
            
            # Re-write the file strictly with valid content lines
            [System.IO.File]::WriteAllLines($ExportFile, $AllLines, [System.Text.Encoding]::UTF8)
        }
        $WriteSuccess = $true
        Write-Host "System details successfully appended as row #$Count to $ExportFile (no empty lines)." -ForegroundColor Green
    } catch {
        Write-Host "`n[ERROR] Unable to write to '$ExportFile'." -ForegroundColor Red
        Write-Host "Please ensure the CSV file is CLOSED in Microsoft Excel." -ForegroundColor Yellow
        $choice = Read-Host "Close Excel and press [Enter] to retry, or type 'Q' to cancel"
        if ($choice -match '^[Qq]') {
            Write-Host "Operation cancelled." -ForegroundColor Red
            break
        }
    }
}
