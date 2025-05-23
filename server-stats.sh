#!/bin/bash

# Server Performance Statistics Script
# This script analyzes basic server performance metrics

# Colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Function to print subsection headers
print_subheader() {
    echo -e "\n${CYAN}--- $1 ---${NC}"
}

# Main function to display server stats
show_server_stats() {
    echo -e "${GREEN}Server Performance Statistics${NC}"
    echo -e "${GREEN}Generated on: $(date)${NC}"
    echo -e "${GREEN}Hostname: $(hostname)${NC}"
    echo -e "${GREEN}Uptime: $(uptime -p)${NC}"

    # CPU Usage
    print_header "CPU USAGE"
    
    # Get CPU usage using top command (1 iteration, 1 second delay)
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | sed 's/%id,//')
    
    # Alternative method using /proc/stat for more accurate CPU usage
    cpu_line=$(head -n1 /proc/stat)
    cpu_sum=$(echo $cpu_line | awk '{print $2+$3+$4+$5+$6+$7+$8}')
    cpu_idle_proc=$(echo $cpu_line | awk '{print $5}')
    cpu_used_proc=$(echo "$cpu_sum - $cpu_idle_proc" | bc -l 2>/dev/null || echo "$cpu_sum $cpu_idle_proc" | awk '{print $1-$2}')
    cpu_percentage=$(echo "scale=2; ($cpu_used_proc * 100) / $cpu_sum" | bc -l 2>/dev/null || echo "$cpu_used_proc $cpu_sum" | awk '{printf "%.2f", ($1*100)/$2}')
    
    echo -e "Total CPU Usage: ${YELLOW}${cpu_percentage}%${NC}"
    
    # Display CPU cores info
    cpu_cores=$(nproc)
    echo -e "CPU Cores: ${cpu_cores}"
    
    # Load Average
    load_avg=$(uptime | awk -F'load average:' '{print $2}')
    echo -e "Load Average:${load_avg}"

    # Memory Usage
    print_header "MEMORY USAGE"
    
    # Parse memory information from /proc/meminfo
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_free=$(grep MemFree /proc/meminfo | awk '{print $2}')
    mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    mem_buffers=$(grep Buffers /proc/meminfo | awk '{print $2}')
    mem_cached=$(grep '^Cached:' /proc/meminfo | awk '{print $2}')
    
    # Calculate memory usage
    mem_used=$((mem_total - mem_available))
    mem_used_percentage=$(echo "scale=2; ($mem_used * 100) / $mem_total" | bc -l 2>/dev/null || echo "$mem_used $mem_total" | awk '{printf "%.2f", ($1*100)/$2}')
    mem_free_percentage=$(echo "scale=2; ($mem_available * 100) / $mem_total" | bc -l 2>/dev/null || echo "$mem_available $mem_total" | awk '{printf "%.2f", ($1*100)/$2}')
    
    # Convert to human readable format
    mem_total_mb=$((mem_total / 1024))
    mem_used_mb=$((mem_used / 1024))
    mem_available_mb=$((mem_available / 1024))
    
    echo -e "Total Memory: ${mem_total_mb} MB"
    echo -e "Used Memory: ${RED}${mem_used_mb} MB (${mem_used_percentage}%)${NC}"
    echo -e "Available Memory: ${GREEN}${mem_available_mb} MB (${mem_free_percentage}%)${NC}"
    
    # Swap Usage
    swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
    
    if [ "$swap_total" -gt 0 ]; then
        swap_used=$((swap_total - swap_free))
        swap_used_percentage=$(echo "scale=2; ($swap_used * 100) / $swap_total" | bc -l 2>/dev/null || echo "$swap_used $swap_total" | awk '{printf "%.2f", ($1*100)/$2}')
        swap_total_mb=$((swap_total / 1024))
        swap_used_mb=$((swap_used / 1024))
        
        echo -e "Swap Total: ${swap_total_mb} MB"
        echo -e "Swap Used: ${YELLOW}${swap_used_mb} MB (${swap_used_percentage}%)${NC}"
    else
        echo -e "Swap: ${YELLOW}Not configured${NC}"
    fi

    # Disk Usage
    print_header "DISK USAGE"
    
    echo -e "${YELLOW}Filesystem Usage:${NC}"
    df -h | grep -E '^/dev/' | while read line; do
        filesystem=$(echo $line | awk '{print $1}')
        size=$(echo $line | awk '{print $2}')
        used=$(echo $line | awk '{print $3}')
        available=$(echo $line | awk '{print $4}')
        percentage=$(echo $line | awk '{print $5}')
        mountpoint=$(echo $line | awk '{print $6}')
        
        # Color code based on usage percentage
        usage_num=$(echo $percentage | sed 's/%//')
        if [ "$usage_num" -gt 90 ]; then
            color=$RED
        elif [ "$usage_num" -gt 70 ]; then
            color=$YELLOW
        else
            color=$GREEN
        fi
        
        echo -e "${filesystem} (${mountpoint}): ${color}${used}/${size} (${percentage}) - Available: ${available}${NC}"
    done
    
    # Show total disk space summary
    echo -e "\n${YELLOW}Disk Space Summary:${NC}"
    df -h --total | tail -1 | awk '{printf "Total: %s, Used: %s, Available: %s, Usage: %s\n", $2, $3, $4, $5}'

    # Top 5 Processes by CPU Usage
    print_header "TOP 5 PROCESSES BY CPU USAGE"
    
    echo -e "${YELLOW}PID\tUSER\t%CPU\t%MEM\tCOMMAND${NC}"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%-8s %-10s %-6s %-6s %s\n", $2, $1, $3, $4, $11}'

    # Top 5 Processes by Memory Usage
    print_header "TOP 5 PROCESSES BY MEMORY USAGE"
    
    echo -e "${YELLOW}PID\tUSER\t%CPU\t%MEM\tCOMMAND${NC}"
    ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%-8s %-10s %-6s %-6s %s\n", $2, $1, $3, $4, $11}'

    # Network Information (bonus)
    print_header "NETWORK INTERFACES"
    
    ip -brief addr show | grep -E '^(eth|ens|enp|wlan)' | while read line; do
        interface=$(echo $line | awk '{print $1}')
        status=$(echo $line | awk '{print $2}')
        ip_addr=$(echo $line | awk '{print $3}' | cut -d'/' -f1)
        
        if [ "$status" = "UP" ]; then
            color=$GREEN
        else
            color=$RED
        fi
        
        echo -e "${interface}: ${color}${status}${NC} - ${ip_addr}"
    done

    print_header "SUMMARY COMPLETE"
    echo -e "${GREEN}Server statistics collection completed successfully!${NC}"
}

# Check if running as root and show warning
check_permissions() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${YELLOW}Warning: Running as root. Some process information may be more detailed.${NC}"
    fi
}

# Main execution
main() {
    clear
    check_permissions
    show_server_stats
}

# Help function
show_help() {
    echo "Server Statistics Script"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo ""
    echo "This script displays:"
    echo "  - CPU usage and load average"
    echo "  - Memory usage (RAM and Swap)"
    echo "  - Disk usage for all mounted filesystems"
    echo "  - Top 5 processes by CPU usage"
    echo "  - Top 5 processes by memory usage"
    echo "  - Network interface status"
}

# Version function
show_version() {
    echo "Server Statistics Script v1.0"
    echo "Compatible with most Linux distributions"
}

# Parse command line arguments
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        show_version
        exit 0
        ;;
    "")
        main
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use -h or --help for usage information"
        exit 1
        ;;
esac
