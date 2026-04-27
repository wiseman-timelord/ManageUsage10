# ================================================
# Disk Activity Monitor - 60 Second Snapshot
# Top apps by disk usage + % contribution
# ================================================

Clear-Host
Write-Host "=== 60-Second Disk Activity Monitor Starting ===" -ForegroundColor Cyan
Write-Host "Monitoring disk I/O for 60 seconds... (Please keep the PC as idle as possible)" -ForegroundColor Yellow
Write-Host "=================================================`n"

# Collect data over 60 seconds (1 sample per second)
Write-Host "Collecting samples... This will take about 60 seconds." -ForegroundColor Gray

$ioSamples = @()
$totalDiskSamples = @()

1..60 | ForEach-Object {
    # Get per-process IO
    $ioData = Get-Counter '\Process(*)\IO Data Bytes/sec' -ErrorAction SilentlyContinue
    if ($ioData) {
        $ioSamples += $ioData
    }

    # Get total disk activity
    $totalDisk = Get-Counter '\PhysicalDisk(_Total)\Disk Bytes/sec' -ErrorAction SilentlyContinue
    if ($totalDisk) {
        $totalDiskSamples += $totalDisk
    }

    # Show simple progress
    if ($_ % 10 -eq 0) {
        Write-Host "  Progress: $_ / 60 seconds" -NoNewline
        Write-Host "`r" -NoNewline
    }
    Start-Sleep -Seconds 1
}

Write-Host "`n`nMonitoring complete. Processing results..." -ForegroundColor Green

# === 1. Total Disk Activity Summary ===
Write-Host "`n1. Total Disk Activity Over 60 Seconds" -ForegroundColor Yellow

$avgTotalIO = if ($totalDiskSamples.Count -gt 0) {
    [math]::Round(($totalDiskSamples | ForEach-Object { $_.CounterSamples[0].CookedValue } | Measure-Object -Average).Average)
} else { 0 }

$maxTotalIO = if ($totalDiskSamples.Count -gt 0) {
    [math]::Round(($totalDiskSamples | ForEach-Object { $_.CounterSamples[0].CookedValue } | Measure-Object -Maximum).Maximum)
} else { 0 }

Write-Host "Average Disk Usage : $avgTotalIO Bytes/sec  (~ $([math]::Round($avgTotalIO / 1MB, 2)) MB/sec)"
Write-Host "Peak Disk Usage    : $maxTotalIO Bytes/sec"

# Approximate % Disk Time (busy percentage) - using % Disk Time counter
$diskTimeSamples = Get-Counter '\PhysicalDisk(_Total)\% Disk Time' -SampleInterval 1 -MaxSamples 5 -ErrorAction SilentlyContinue
$avgDiskTime = if ($diskTimeSamples) {
    [math]::Round(($diskTimeSamples.CounterSamples | Measure-Object -Property CookedValue -Average).Average, 1)
} else { "N/A" }

Write-Host "Average Disk Busy Time : $avgDiskTime %" -ForegroundColor White

# === 2. Top Processes by Average I/O ===
Write-Host "`n2. Top Processes by Average Disk I/O (over 60 seconds)" -ForegroundColor Yellow
Write-Host "Process Name          Avg Bytes/sec   % of Total Disk Activity" -ForegroundColor Gray

# Aggregate IO data per process
$processIO = @{}

foreach ($sampleSet in $ioSamples) {
    foreach ($sample in $sampleSet.CounterSamples) {
        $procName = $sample.InstanceName -replace '#\d+$', ''
        if ($procName -eq '_Total' -or $procName -eq 'Idle') { continue }

        if (-not $processIO.ContainsKey($procName)) {
            $processIO[$procName] = @()
        }
        $processIO[$procName] += $sample.CookedValue
    }
}

# Calculate averages and percentages
$topProcesses = $processIO.GetEnumerator() | ForEach-Object {
    $avgIO = [math]::Round(($_.Value | Measure-Object -Average).Average)
    $percent = if ($avgTotalIO -gt 0) { [math]::Round(($avgIO / $avgTotalIO) * 100, 1) } else { 0 }
    [PSCustomObject]@{
        Process       = $_.Key
        'Avg Bytes/sec' = $avgIO
        'Percent of Total' = "$percent%"
    }
} | Sort-Object 'Avg Bytes/sec' -Descending | Select-Object -First 15

$topProcesses | Format-Table -AutoSize

if ($topProcesses.Count -eq 0) {
    Write-Host "   No significant disk activity detected." -ForegroundColor Green
}

# === 3. Summary ===
Write-Host "`n=== SUMMARY ===" -ForegroundColor Magenta
Write-Host "• Average disk activity: $avgTotalIO Bytes/sec ($avgDiskTime% busy)"
Write-Host "• Look at processes with high 'Percent of Total' — these are the main contributors."
Write-Host "• If VLC or OneSyncSvc still appear high, they are likely the cause."

Write-Host "`nCopy the entire output above and reply with it." -ForegroundColor Yellow
Write-Host "I will analyze the top processes and give you targeted fix commands."

# Optional: Save report
$desktop = [Environment]::GetFolderPath("Desktop")
$logFile = Join-Path $desktop "Disk_60s_Monitor_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
"Disk Activity Report - $(Get-Date)`n`nAverage Disk: $avgTotalIO Bytes/sec`n`n$($topProcesses | Out-String)" | Out-File $logFile -Encoding UTF8
Write-Host "`nFull report saved to: $logFile" -ForegroundColor Green