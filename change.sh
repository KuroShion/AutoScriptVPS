#!/bin/bash

# Define colors for output
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
NC='\e[0m'

# Get the server's public IP
MYIP=$(wget -qO- https://icanhazip.com)

# Display header
clear
echo -e "${blue}======================================${NC}"
echo -e "${green}          VPS Port Management          ${NC}"
echo -e "${blue}======================================${NC}"
echo -e ""

# Display menu options
echo -e "${yellow}     [1]  Change Port Stunnel4${NC}"
echo -e "${yellow}     [2]  Change Port OpenVPN${NC}"
echo -e "${yellow}     [3]  Change Port Wireguard${NC}"
echo -e "${yellow}     [4]  Change Port Vmess${NC}"
echo -e "${yellow}     [5]  Change Port Vless${NC}"
echo -e "${yellow}     [6]  Change Port Trojan${NC}"
echo -e "${yellow}     [7]  Change Port Squid${NC}"
echo -e "${yellow}     [8]  Change Port SSTP${NC}"
echo -e "${red}     [x]  Exit${NC}"
echo -e ""
echo -e "${blue}======================================${NC}"
echo -e ""

# Prompt user for input
read -p "     Select From Options [1-8 or x]: " port
echo -e ""

# Handle user input
case $port in
1)
    echo -e "${green}Changing Port for Stunnel4...${NC}"
    port-ssl
    ;;
2)
    echo -e "${green}Changing Port for OpenVPN...${NC}"
    port-ovpn
    ;;
3)
    echo -e "${green}Changing Port for Wireguard...${NC}"
    port-wg
    ;;
4)
    echo -e "${green}Changing Port for Vmess...${NC}"
    port-ws
    ;;
5)
    echo -e "${green}Changing Port for Vless...${NC}"
    port-vless
    ;;
6)
    echo -e "${green}Changing Port for Trojan...${NC}"
    port-tr
    ;;
7)
    echo -e "${green}Changing Port for Squid...${NC}"
    port-squid
    ;;
8)
    echo -e "${green}Changing Port for SSTP...${NC}"
    port-sstp
    ;;
x)
    echo -e "${red}Exiting to main menu...${NC}"
    clear
    menu
    ;;
*)
    echo -e "${red}Invalid option. Please enter a correct number.${NC}"
    ;;
esac