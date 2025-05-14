#!/bin/bash
# Script Auto Reboot VPS
# Created By EvoTeamMalaysia

RED='\e[1;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'

# Auto Reboot
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"

# Check if /home/autoreboot exists
if [[ ! -f /home/autoreboot ]]; then
    echo "stop" > /home/autoreboot
fi

cek=$(cat /home/autoreboot)

function start () {
    echo "0 0 * * * root /usr/bin/reboot" > /etc/cron.d/reboot
    echo "start" > /home/autoreboot
    echo -e "${GREEN}Auto Reboot has been enabled. The server will reboot daily at 00:00.${NC}"
}

function stop () {
    rm -f /etc/cron.d/reboot
    sleep 0.5
    echo "stop" > /home/autoreboot
    echo -e "${RED}Auto Reboot has been disabled.${NC}"
}

# Status Auto Reboot
if [[ "$cek" = "start" ]]; then
    sts="${Info}"
else
    sts="${Error}"
fi

# Display Menu
clear
echo -e "${GREEN}========================================================= ${NC}"
figlet Auto Reboot | lolcat
echo -e "${GREEN}========================================================= ${NC}"
echo -e "Auto Reboot Status: $sts"
echo -e ""
echo -e "      1. Start Auto Reboot"
echo -e "      2. Stop Auto Reboot"
echo -e ""
echo -e "Press CTRL+C to return to the main menu."
read -rp "Please Enter Your Choice (1 or 2): " -e num

# Handle User Input
if [[ "$num" = "1" ]]; then
    start
elif [[ "$num" = "2" ]]; then
    stop
else
    echo -e "${RED}Invalid input. Please enter 1 to start or 2 to stop.${NC}"
fi