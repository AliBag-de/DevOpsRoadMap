# Server Statistics Script
 https://roadmap.sh/projects/server-stats <br/>
 A comprehensive bash script for monitoring basic server performance statistics on Linux systems.

## Features

The `server-stats.sh` script provides the following information:

- **CPU Usage**: Total CPU utilization percentage and load average
- **Memory Usage**: RAM and Swap usage with percentages (Free vs Used)
- **Disk Usage**: File system usage for all mounted drives with percentages
- **Top 5 Processes by CPU Usage**: Most CPU-intensive processes
- **Top 5 Processes by Memory Usage**: Most memory-intensive processes
- **Network Interfaces**: Status of network interfaces (bonus feature)
- **System Information**: Hostname, uptime, and timestamp

## Requirements

- Linux operating system (tested on Ubuntu, CentOS, RHEL, Debian)
- Bash shell
- Standard Linux utilities: `ps`, `df`, `top`, `grep`, `awk`, `bc` (usually pre-installed)

## Installation

1. Download or copy the script to your server:
   ```bash
   wget https://raw.githubusercontent.com/your-repo/server-stats.sh
   # or
   curl -O https://raw.githubusercontent.com/your-repo/server-stats.sh
   ```

2. Make the script executable:
   ```bash
   chmod +x server-stats.sh
   ```

3. Optionally, move it to a directory in your PATH for system-wide access:
   ```bash
   sudo mv server-stats.sh /usr/local/bin/
   ```

## Usage

### Basic Usage

Run the script directly:
```bash
./server-stats.sh
```

If installed system-wide:
```bash
server-stats.sh
```

### Command Line Options

- **Help**: Display usage information
  ```bash
  ./server-stats.sh -h
  # or
  ./server-stats.sh --help
  ```

- **Version**: Show version information
  ```bash
  ./server-stats.sh -v
  # or
  ./server-stats.sh --version
  ```

### Examples

**Standard execution:**
```bash
$ ./server-stats.sh
Server Performance Statistics
Generated on: Fri May 23 10:30:15 UTC 2025
Hostname: web-server-01
Uptime: up 5 days, 2 hours, 30 minutes

========================================
CPU USAGE
========================================
Total CPU Usage: 15.32%
CPU Cores: 4
Load Average: 0.85, 0.92, 1.02

========================================
MEMORY USAGE
========================================
Total Memory: 8192 MB
Used Memory: 6144 MB (75.00%)
Available Memory: 2048 MB (25.00%)
Swap Total: 2048 MB
Swap Used: 512 MB (25.00%)
```

## Output Explanation

### CPU Usage Section
- **Total CPU Usage**: Percentage of CPU currently in use
- **CPU Cores**: Number of available CPU cores
- **Load Average**: System load over 1, 5, and 15 minutes

### Memory Usage Section
- **Total Memory**: Total RAM available
- **Used Memory**: Currently used RAM with percentage
- **Available Memory**: Available RAM including buffers/cache
- **Swap Usage**: Virtual memory usage (if configured)

### Disk Usage Section
- **Filesystem Usage**: Usage for each mounted filesystem
- **Color coding**: 
  - Green: < 70% usage
  - Yellow: 70-90% usage
  - Red: > 90% usage

### Process Information
- **Top 5 by CPU**: Processes consuming most CPU resources
- **Top 5 by Memory**: Processes consuming most memory
- Displays: PID, User, CPU%, Memory%, Command

## Permissions

The script can run with regular user privileges, but running as root may provide more detailed process information. A warning is displayed when running as root.

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x server-stats.sh
   ```

2. **Command not found: bc**
   - Ubuntu/Debian: `sudo apt-get install bc`
   - CentOS/RHEL: `sudo yum install bc`

3. **No color output**
   - The script should work on most terminals. If colors don't appear, the script will still function properly.

### Dependencies Check

Verify required tools are installed:
```bash
which ps df top grep awk bc
```

## Compatibility

Tested on:
- Ubuntu 18.04, 20.04, 22.04
- CentOS 7, 8
- RHEL 7, 8, 9
- Debian 9, 10, 11
- Amazon Linux 2

## Automation

### Cron Job Setup

To run the script automatically and save output to a log file:

```bash
# Edit crontab
crontab -e

# Add entry to run every hour
0 * * * * /path/to/server-stats.sh >> /var/log/server-stats.log 2>&1

# Or run every 15 minutes
*/15 * * * * /path/to/server-stats.sh >> /var/log/server-stats.log 2>&1
```

### Logging to File

Save output to a file:
```bash
./server-stats.sh > server-stats-$(date +%Y%m%d-%H%M%S).log
```

## Customization

The script can be easily modified to:
- Add more metrics
- Change color schemes
- Modify output format
- Add email notifications
- Integrate with monitoring systems

## Security Considerations

- The script only reads system information and doesn't modify anything
- Safe to run in production environments
- No network connections are made
- No sensitive information is exposed

## License

This script is provided as-is for educational and operational purposes. Feel free to modify and distribute.

## Contributing

Suggestions and improvements are welcome. Please test thoroughly before submitting changes.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Verify system compatibility
3. Ensure all dependencies are installed
4. Test with minimal permissions first
