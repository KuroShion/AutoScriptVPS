#!/bin/bash

# Define colors for output
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'

# Get the server's public IP
MYIP=$(wget -qO- https://icanhazip.com)

# Check VPS
echo -e "${green}Checking VPS...${NC}"
sleep 0.7

# Load configuration
if [ -f /var/lib/premium-script/ipvps.conf ]; then
    source /var/lib/premium-script/ipvps.conf
else
    echo -e "${red}Error: Configuration file not found!${NC}"
    exit 1
fi

# Ensure the domain variable is set
if [ -z "$IP" ]; then
    echo -e "${red}Error: IP variable is not set in the configuration file!${NC}"
    exit 1
fi
domain=$IP

# Stop V2Ray services
echo -e "${green}Stopping V2Ray services...${NC}"
systemctl stop v2ray || { echo -e "${red}Failed to stop v2ray!${NC}"; exit 1; }
systemctl stop v2ray@none || { echo -e "${red}Failed to stop v2ray@none!${NC}"; exit 1; }

# Issue and install certificate
echo -e "${green}Issuing and installing SSL certificate...${NC}"
if ! /root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256; then
    echo -e "${red}Failed to issue certificate!${NC}"
    exit 1
fi

if ! ~/.acme.sh/acme.sh --installcert -d "$domain" \
    --fullchainpath /etc/v2ray/v2ray.crt \
    --keypath /etc/v2ray/v2ray.key --ecc; then
    echo -e "${red}Failed to install certificate!${NC}"
    exit 1
fi

# Start V2Ray services
echo -e "${green}Starting V2Ray services...${NC}"
systemctl start v2ray || { echo -e "${red}Failed to start v2ray!${NC}"; exit 1; }
systemctl start v2ray@none || { echo -e "${red}Failed to start v2ray@none!${NC}"; exit 1; }

# Completion message
echo -e "${green}SSL certificate installation completed successfully!${NC}"

# Confirm reboot
read -p "The system will reboot in 5 seconds. Do you want to proceed? (y/n): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${green}Rebooting...${NC}"
    sleep 5
    reboot
else
    echo -e "${green}Reboot canceled.${NC}"
fi