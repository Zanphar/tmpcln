### tmpcln
This used to be a batch file then moved over to a PowerShell script for additional features and functionality. 

**This script will perform the following actions:**
1. Stop the Windows Update Service (to clear cache).
2. Delete all files in C:\Windows\SoftwareDistribution (Windows Update leftovers).
3. Empty System Temp and User Temp folders.
4. Clear the Prefetch folder (cached application launch data).
5. Empty the Recycle Bin.
