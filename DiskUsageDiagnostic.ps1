# ================================================
# Windows 10 Idle Disk Activity Diagnostics - Single Run
# One-time comprehensive report (no live loop)
# ================================================

Clear-Host
Write-Host "=== Windows 10 Idle Disk Activity Diagnostics ===" -ForegroundColor Cyan
Write-Host "Generated on: $(Get-Date)" -ForegroundColor Gray
Write-Host "=================================================`n" -ForegroundColor Cyan

# 1. Overall System Disk Activity (multiple samples for average)
Write-Host "1. Overall Disk Activity (5 samples)" -ForegroundColor Yellow
$diskActivity = Get-Counter -Counter '\PhysicalDisk(_Total)\Disk Bytes/sec' -SampleInterval 1 -MaxSamples 5
$diskActivity.CounterSamples | 
    Select-Object @{Name='Time';Expression={Get-Date -Format 'HH:mm:ss'}}, 
                  @{Name='Total Disk Bytes/sec';Expression={[math]::Round($_.CookedValue)}} |
    Format-Table -AutoSize

$avgDisk = [math]::Round(($diskActivity.CounterSamples | Measure-Object -Property CookedValue -Average).Average)
Write-Host "Average Disk Activity: $avgDisk Bytes/sec" -ForegroundColor Green

# 2. Top Processes by Disk I/O (detailed snapshot)
Write-Host "`n2. Top 20 Processes by Current Disk I/O Activity" -ForegroundColor Yellow
$topIO = Get-Counter '\Process(*)\IO Data Bytes/sec' -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty CounterSamples |
    Where-Object { $_.CookedValue -gt 500 } |   # Only show meaningful activity (>500 B/s)
    Sort-Object CookedValue -Descending |
    Select-Object @{Name='Process';Expression={ $_.InstanceName -replace '#\d+','' }},
                  @{Name='IO Bytes/sec';Expression={[math]::Round($_.CookedValue)}},
                  @{Name='IO MB/sec';Expression={[math]::Round($_.CookedValue / 1MB, 2)}} -First 20

$topIO | Format-Table -AutoSize

if ($topIO.Count -eq 0) {
    Write-Host "   No significant disk I/O detected from processes." -ForegroundColor Green
}

# 3. Common Problematic Services Status
Write-Host "`n3. Common Services That Often Cause High Idle Disk Usage" -ForegroundColor Yellow
$serviceNames = @('SysMain', 'WSearch', 'WinDefend', 'DiagTrack', 'BITS', 'wuauserv', 'OneSyncSvc*', 'WerSvc', 'DPS')

Get-Service -Name $serviceNames -ErrorAction SilentlyContinue |
    Select-Object Name, DisplayName, Status, StartType |
    Sort-Object Status -Descending |
    Format-Table -AutoSize

# 4. Additional Useful Counters
Write-Host "`n4. Additional Disk & Memory Counters" -ForegroundColor Yellow
Write-Host "Pagefile Usage (MB):" -NoNewline
(Get-Counter '\Paging File(*)\% Usage' -ErrorAction SilentlyContinue).CounterSamples |
    Select-Object @{Name='Usage %';Expression={[math]::Round($_.CookedValue, 1)}} |
    Format-Table -AutoSize -HideTableHeaders

Write-Host "`nDisk Queue Length (should be low when idle):"
Get-Counter '\PhysicalDisk(_Total)\Avg. Disk Queue Length' -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty CounterSamples |
    Select-Object @{Name='Avg Queue Length';Expression={[math]::Round($_.CookedValue, 2)}} |
    Format-Table -AutoSize

# 5. Summary & Recommendations
Write-Host "`n=== SUMMARY & NEXT STEPS ===" -ForegroundColor Magenta

Write-Host "• If average disk activity is consistently above 5-10 MB/s while idle → high activity" -ForegroundColor White
Write-Host "• Look at the Top Processes section above. Processes with > 1 MB/sec are suspicious." -ForegroundColor White

Write-Host "`nCommon culprits (in order of likelihood):" -ForegroundColor Cyan
Write-Host "  1. SysMain (Superfetch)"
Write-Host "  2. Windows Search (WSearch) - indexing"
Write-Host "  3. Windows Defender (WinDefend)"
Write-Host "  4. DiagTrack / Connected User Experiences"
Write-Host "  5. OneDrive sync (if installed)"

Write-Host "`nCopy and paste the entire output above when you reply." -ForegroundColor Yellow
Write-Host "I will analyze the results and tell you exactly what to disable or fix." -ForegroundColor Yellow

# Optional: Save output to desktop for easy sharing
$desktopPath = [Environment]::GetFolderPath("Desktop")
$logPath = Join-Path $desktopPath "Disk_Diagnostics_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$Output = @"
Windows 10 Disk Diagnostics - $(Get-Date)
Average Disk Activity: $avgDisk Bytes/sec

Top Processes:
$($topIO | Out-String)

Services:
$((Get-Service -Name $serviceNames -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType | Out-String))
"@

$Output | Out-File -FilePath $logPath -Encoding UTF8
Write-Host "`nFull report also saved to: $logPath" -ForegroundColor Green# ================================================
# Windows 10 Idle Disk Activity Diagnostics - Single Run
# One-time comprehensive report (no live loop)
# ================================================

Clear-Host
Write-Host "=== Windows 10 Idle Disk Activity Diagnostics ===" -ForegroundColor Cyan
Write-Host "Generated on: $(Get-Date)" -ForegroundColor Gray
Write-Host "=================================================`n" -ForegroundColor Cyan

# 1. Overall System Disk Activity (multiple samples for average)
Write-Host "1. Overall Disk Activity (5 samples)" -ForegroundColor Yellow
$diskActivity = Get-Counter -Counter '\PhysicalDisk(_Total)\Disk Bytes/sec' -SampleInterval 1 -MaxSamples 5
$diskActivity.CounterSamples | 
    Select-Object @{Name='Time';Expression={Get-Date -Format 'HH:mm:ss'}}, 
                  @{Name='Total Disk Bytes/sec';Expression={[math]::Round($_.CookedValue)}} |
    Format-Table -AutoSize

$avgDisk = [math]::Round(($diskActivity.CounterSamples | Measure-Object -Property CookedValue -Average).Average)
Write-Host "Average Disk Activity: $avgDisk Bytes/sec" -ForegroundColor Green

# 2. Top Processes by Disk I/O (detailed snapshot)
Write-Host "`n2. Top 20 Processes by Current Disk I/O Activity" -ForegroundColor Yellow
$topIO = Get-Counter '\Process(*)\IO Data Bytes/sec' -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty CounterSamples |
    Where-Object { $_.CookedValue -gt 500 } |   # Only show meaningful activity (>500 B/s)
    Sort-Object CookedValue -Descending |
    Select-Object @{Name='Process';Expression={ $_.InstanceName -replace '#\d+','' }},
                  @{Name='IO Bytes/sec';Expression={[math]::Round($_.CookedValue)}},
                  @{Name='IO MB/sec';Expression={[math]::Round($_.CookedValue / 1MB, 2)}} -First 20

$topIO | Format-Table -AutoSize

if ($topIO.Count -eq 0) {
    Write-Host "   No significant disk I/O detected from processes." -ForegroundColor Green
}

# 3. Common Problematic Services Status
Write-Host "`n3. Common Services That Often Cause High Idle Disk Usage" -ForegroundColor Yellow
$serviceNames = @('SysMain', 'WSearch', 'WinDefend', 'DiagTrack', 'BITS', 'wuauserv', 'OneSyncSvc*', 'WerSvc', 'DPS')

Get-Service -Name $serviceNames -ErrorAction SilentlyContinue |
    Select-Object Name, DisplayName, Status, StartType |
    Sort-Object Status -Descending |
    Format-Table -AutoSize

# 4. Additional Useful Counters
Write-Host "`n4. Additional Disk & Memory Counters" -ForegroundColor Yellow
Write-Host "Pagefile Usage (MB):" -NoNewline
(Get-Counter '\Paging File(*)\% Usage' -ErrorAction SilentlyContinue).CounterSamples |
    Select-Object @{Name='Usage %';Expression={[math]::Round($_.CookedValue, 1)}} |
    Format-Table -AutoSize -HideTableHeaders

Write-Host "`nDisk Queue Length (should be low when idle):"
Get-Counter '\PhysicalDisk(_Total)\Avg. Disk Queue Length' -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty CounterSamples |
    Select-Object @{Name='Avg Queue Length';Expression={[math]::Round($_.CookedValue, 2)}} |
    Format-Table -AutoSize

# 5. Summary & Recommendations
Write-Host "`n=== SUMMARY & NEXT STEPS ===" -ForegroundColor Magenta

Write-Host "• If average disk activity is consistently above 5-10 MB/s while idle → high activity" -ForegroundColor White
Write-Host "• Look at the Top Processes section above. Processes with > 1 MB/sec are suspicious." -ForegroundColor White

Write-Host "`nCommon culprits (in order of likelihood):" -ForegroundColor Cyan
Write-Host "  1. SysMain (Superfetch)"
Write-Host "  2. Windows Search (WSearch) - indexing"
Write-Host "  3. Windows Defender (WinDefend)"
Write-Host "  4. DiagTrack / Connected User Experiences"
Write-Host "  5. OneDrive sync (if installed)"

Write-Host "`nCopy and paste the entire output above when you reply." -ForegroundColor Yellow
Write-Host "I will analyze the results and tell you exactly what to disable or fix." -ForegroundColor Yellow

# Optional: Save output to desktop for easy sharing
$desktopPath = [Environment]::GetFolderPath("Desktop")
$logPath = Join-Path $desktopPath "Disk_Diagnostics_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$Output = @"
Windows 10 Disk Diagnostics - $(Get-Date)
Average Disk Activity: $avgDisk Bytes/sec

Top Processes:
$($topIO | Out-String)

Services:
$((Get-Service -Name $serviceNames -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType | Out-String))
"@

$Output | Out-File -FilePath $logPath -Encoding UTF8
Write-Host "`nFull report also saved to: $logPath" -ForegroundColor Green