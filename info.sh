#!/bin/bash

# Clear the screen
clear

# Display system information using neofetch
neofetch

# Display additional system information
echo -e "\n============================================="
echo -e "           Script Information"
echo -e "============================================="
echo -e "Script By: EvoTeamMalaysia"
echo -e "Telegram: https://t.me/EvoTeamMalaysia"
echo -e "GitHub: https://github.com/EvoTeamMalaysia"
echo -e "============================================="

# Display server information
echo -e "\n============================================="
echo -e "           Server Information"
echo -e "============================================="
echo -e "Hostname: $(hostname)"
echo -e "Public IP: $(wget -qO- https://icanhazip.com)"
echo -e "Operating System: $(lsb_release -d | awk -F'\t' '{print $2}')"
echo -e "Kernel: $(uname -r)"
echo -e "Uptime: $(uptime -p)"
echo -e "============================================="
