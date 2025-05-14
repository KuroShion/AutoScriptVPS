#!/bin/bash

# Define colors for output
RED='\e[1;31m'
GREEN='\e[0;32m'
NC='\e[0m'

# Get the server's public IP
MYIP=$(wget -qO- https://icanhazip.com)

# Check VPS
echo -e "${GREEN}Checking VPS...${NC}"
clear

# Extract PPTP VPN user login information
last | grep ppp | grep still | awk '{print " ",$1," - " $3 }' > /tmp/login-db-pptp.txt

# Check if there are any active PPTP VPN users
if [ ! -s /tmp/login-db-pptp.txt ]; then
    echo -e "${RED}No active PPTP VPN users found.${NC}"
    rm -f /tmp/login-db-pptp.txt
    exit 0
fi

# Display the login information
echo -e "${GREEN}===========================================${NC}"
echo -e " "
echo -e "${BLUE}-------------------------------------${NC}"
echo -e "           PPTP VPN User Login"
echo -e "${BLUE}-------------------------------------${NC}"
echo -e "Username   ---   IP"
echo -e "${BLUE}-------------------------------------${NC}"
cat /tmp/login-db-pptp.txt
echo -e "${BLUE}-------------------------------------${NC}"
echo -e " "
echo -e "${GREEN}===========================================${NC}"

# Clean up temporary file
rm -f /tmp/login-db-pptp.txt