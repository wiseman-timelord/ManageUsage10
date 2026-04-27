# ManageUsage10
Status: Alpha

### Description
This is a program to diagnose resource usage on windows 10, it could potentially monitor specified resources from a menu, ie not just disk usage, but here is the current drive usage output....
```
=== 60-Second Disk Activity Monitor Starting ===
Monitoring disk I/O for 60 seconds... (Please keep the PC as idle as possible)
=================================================

Collecting samples... This will take about 60 seconds.
  Progress: 60 / 60 seconds

Monitoring complete. Processing results...

1. Total Disk Activity Over 60 Seconds
Average Disk Usage : 40263 Bytes/sec  (~ 0.04 MB/sec)
Peak Disk Usage    : 569471 Bytes/sec
Average Disk Busy Time : 0 %

2. Top Processes by Average Disk I/O (over 60 seconds)
Process Name          Avg Bytes/sec   % of Total Disk Activity

Process          Avg Bytes/sec Percent of Total
-------          ------------- ----------------
msedge                22597.00 56.1%
registry               1157.00 2.9%
svchost                 762.00 1.9%
system                  539.00 1.3%
fastedit                155.00 0.4%
csrss                    89.00 0.2%
msedgewebview2           81.00 0.2%
ccleaner_service         53.00 0.1%
taskhostw                34.00 0.1%
wfcs                     27.00 0.1%
wfc                      27.00 0.1%
pythonw                  26.00 0.1%
dllhost                  23.00 0.1%
ccleaner                 17.00 0%
nvidia overlay           16.00 0%


=== SUMMARY ===
• Average disk activity: 40263 Bytes/sec (0% busy)
• Look at processes with high 'Percent of Total' — these are the main contributors.
• If VLC or OneSyncSvc still appear high, they are likely the cause.

Copy the entire output above and reply with it.
I will analyze the top processes and give you targeted fix commands.

Full report saved to: C:\Users\WiseMan-TimeLord\Desktop\Disk_60s_Monitor_20260427_142100.txt
Press any key to continue . . .
```
...so currently a script to diagnose disk usage, in order to determine best route to reduce blinking of the light and wear on drives/interfaces. 
