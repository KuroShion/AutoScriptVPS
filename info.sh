#!/bin/bash

# Clear the screen
clear

# Check if neofetch is installed, install if missing
if ! command -v neofetch &> /dev/null; then
    echo -e "\e[93m[INFO]\e[0m Installing neofetch..."
    apt-get update -y && apt-get install -y neofetch
fi

# Display system information using neofetch
neofetch

# Display additional script information
echo -e "\n\033[1;36m=============================================\033[0m"
echo -e "                \033[1;33mScript Information\033[0m"
echo -e "\033[1;36m=============================================\033[0m"
echo -e "Script By   : \033[1;32mEvoTeamMalaysia\033[0m"
echo -e "Telegram    : \033[1;34mhttps://t.me/EvoTeamMalaysia\033[0m"
echo -e "GitHub      : \033[1;34mhttps://github.com/EvoTeamMalaysia\033[0m"
echo -e "\033[1;36m=============================================\033[0m"

# Display server information
echo -e "\n\033[1;36m=============================================\033[0m"
echo -e "                \033[1;33mServer Information\033[0m"
echo -e "\033[1;36m=============================================\033[0m"
echo -e "Hostname         : \033[1;32m$(hostname)\033[0m"
echo -e "Public IP        : \033[1;32m$(curl -s https://icanhazip.com)\033[0m"
if command -v lsb_release &> /dev/null; then
    OS_DESC=$(lsb_release -d | awk -F'\t' '{print $2}')
else
    OS_DESC=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
fi
echo -e "Operating System : \033[1;32m$OS_DESC\033[0m"
echo -e "Kernel           : \033[1;32m$(uname -r)\033[0m"
echo -e "Uptime           : \033[1;32m$(uptime -p)\033[0m"
echo -e "CPU              : \033[1;32m$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^ //')\033[0m"
echo -e "CPU Cores        : \033[1;32m$(nproc)\033[0m"
echo -e "RAM Usage        : \033[1;32m$(free -h | awk '/^Mem:/ {print $3 "/" $2}')\033[0m"
echo -e "Swap Usage       : \033[1;32m$(free -h | awk '/^Swap:/ {print $3 "/" $2}')\033[0m"
echo -e "Disk Usage       : \033[1;32m$(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 ")"}')\033[0m"
echo -e "Processes        : \033[1;32m$(ps -e --no-headers | wc -l)\033[0m"
echo -e "Logged In Users  : \033[1;32m$(who | wc -l)\033[0m"
echo -e "Current Date     : \033[1;32m$(date)\033[0m"
echo -e "\033[1;36m=============================================\033[0m"
echo -e "\n\033[1;36m=============================================\033[0m"
echo -e "                \033[1;33mScript Execution Completed\033[0m"
echo -e "\033[1;36m=============================================\033[0m" 
