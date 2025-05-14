#!/bin/bash

# Define colors for output
RED='\e[1;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'

# Clear the screen
clear

# Display the header
echo -e "${RED}=================================================${NC}"
echo -e "          ${RED}Premium Auto Script By EvoTeam${NC}           "
echo -e "${RED}=================================================${NC}"

# Display system information dynamically
echo -e " System Information:"
OS=$(lsb_release -d 2>/dev/null | awk -F"\t" '{print $2}' || echo "Unknown OS")
ARCH=$(uname -m)
echo -e " - Operating System: ${GREEN}${OS}${NC}"
echo -e " - Architecture: ${GREEN}${ARCH}${NC}"

# Display supported systems
echo -e "\n Supported Systems:"
echo -e " - Debian 9 & Debian 10 64 Bit"
echo -e " - Ubuntu 18.04 - Ubuntu 22.10 64 Bit"
echo -e " For VPS with KVM and VMWare virtualization"
echo -e " ${RED}No OpenVZ Virtualization Supported!${NC}"

# Display contact information
echo -e "\n Contact:"
echo -e " - Telegram: ${BLUE}t.me/EvoTeamMalaysia${NC}"

# Display footer
echo -e "${RED}=================================================${NC}"