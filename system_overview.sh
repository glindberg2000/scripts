#!/bin/bash

# Output file
output_file="system_overview_report.txt"

echo "=====================================" > $output_file
echo "  Linux System Overview - $(date)" >> $output_file
echo "=====================================" >> $output_file

# 1. Kernel and OS Information
echo "1. OS and Kernel Information" >> $output_file
echo "-------------------------------------" >> $output_file
uname -a >> $output_file
lsb_release -a >> $output_file 2>/dev/null
echo "" >> $output_file

# 2. Installed Packages
echo "2. Installed Packages" >> $output_file
echo "-------------------------------------" >> $output_file
if command -v dpkg &> /dev/null
then
    dpkg -l >> $output_file
elif command -v rpm &> /dev/null
then
    rpm -qa >> $output_file
elif command -v pacman &> /dev/null
then
    pacman -Q >> $output_file
else
    echo "Package manager not detected" >> $output_file
fi
echo "" >> $output_file

# 3. Currently Running Processes
echo "3. Currently Running Processes" >> $output_file
echo "-------------------------------------" >> $output_file
ps aux --sort=-%mem | head -n 20 >> $output_file
echo "" >> $output_file

# 4. Services (Systemd)
echo "4. Active Services (Systemd)" >> $output_file
echo "-------------------------------------" >> $output_file
systemctl list-units --type=service --state=running >> $output_file
echo "" >> $output_file

# 5. Listening Network Ports
echo "5. Listening Network Ports" >> $output_file
echo "-------------------------------------" >> $output_file
ss -tuln >> $output_file
echo "" >> $output_file

# 6. Disk Usage Information
echo "6. Disk Usage Information" >> $output_file
echo "-------------------------------------" >> $output_file
df -h >> $output_file
echo "" >> $output_file

# 7. Memory and Swap Usage
echo "7. Memory and Swap Usage" >> $output_file
echo "-------------------------------------" >> $output_file
free -h >> $output_file
echo "" >> $output_file

# 8. Crontab Jobs
echo "8. User and System Crontab Jobs" >> $output_file
echo "-------------------------------------" >> $output_file
crontab -l >> $output_file 2>/dev/null || echo "No user crontab found" >> $output_file
cat /etc/crontab >> $output_file
echo "" >> $output_file

# 9. System Logs (Last 20 lines of Syslog)
echo "9. System Logs (Last 20 lines of Syslog)" >> $output_file
echo "-------------------------------------" >> $output_file
tail -n 20 /var/log/syslog >> $output_file 2>/dev/null || echo "Syslog not available" >> $output_file
echo "" >> $output_file

# 10. Users Logged In
echo "10. Currently Logged In Users" >> $output_file
echo "-------------------------------------" >> $output_file
w >> $output_file
echo "" >> $output_file

echo "System overview report generated: $output_file"
