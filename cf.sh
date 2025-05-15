#!/bin/bash

# Define colors for output
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'

# Get the server's public IP
MYIP=$(wget -qO- https://icanhazip.com)
echo "Checking VPS"

# Ensure required packages are installed
if ! command -v jq &> /dev/null || ! command -v curl &> /dev/null; then
    echo -e "${green}Installing required packages...${NC}"
    apt update && apt install jq curl -y
fi

# Configuration
DOMAIN="kayyo.online"
sub=$(</dev/urandom tr -dc a-z0-9 | head -c4)
SUB_DOMAIN="${sub}.kayyo.online"
WILDCARD="*.${sub}.kayyo.online"
CF_ID="5faktadunia@gmail.com"
CF_KEY="b2185bbc8fc43ebbf4132daf1eee48a32b5d3"
IP=$(wget -qO- https://icanhazip.com)

# Function to update DNS
update_dns() {
    local record_name=$1
    echo -e "${green}Updating DNS for ${record_name}...${NC}"

    # Get Zone ID
    ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" | jq -r .result[0].id)

    if [[ -z "$ZONE" || "$ZONE" == "null" ]]; then
        echo -e "${red}Error: Failed to retrieve Zone ID for ${DOMAIN}.${NC}"
        exit 1
    fi

    # Get Record ID
    RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${record_name}" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" | jq -r .result[0].id)

    # Create or Update DNS Record
    if [[ "${#RECORD}" -le 10 ]]; then
        RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
            -H "X-Auth-Email: ${CF_ID}" \
            -H "X-Auth-Key: ${CF_KEY}" \
            -H "Content-Type: application/json" \
            --data '{"type":"A","name":"'${record_name}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
    fi

    RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"'${record_name}'","content":"'${IP}'","ttl":120,"proxied":false}')

    if [[ -z "$RESULT" || "$RESULT" == "null" ]]; then
        echo -e "${red}Error: Failed to update DNS for ${record_name}.${NC}"
        exit 1
    fi

    echo -e "${green}DNS updated successfully for ${record_name}.${NC}"
}

# Function to restart services and log failures
restart_service() {
    local service_name=$1
    local log_file="/var/log/${service_name}_restart.log"

    echo -e "${green}Restarting ${service_name}...${NC}"
    if ! systemctl restart "$service_name" &> "$log_file"; then
        echo -e "${red}Failed to restart ${service_name}. Check the log file: ${log_file}${NC}"
        echo -e "${red}Detailed log (-vvv):${NC}"
        systemctl status "$service_name" -l -n 50 >> "$log_file"
    else
        echo -e "${green}${service_name} restarted successfully.${NC}"
    fi
}

# Update DNS for SUB_DOMAIN and WILDCARD
update_dns "$SUB_DOMAIN"
echo "$SUB_DOMAIN" > /root/domain

update_dns "$WILDCARD"
echo "$WILDCARD" > /home/wildcard

# Completion message
echo -e "${green}DNS records updated successfully!${NC}"
echo -e "${green}Please wait for 5 seconds...${NC}"
sleep 5

# Restart services
restart_service "v2ray"
restart_service "v2ray@none"
restart_service "xray"
restart_service "xray@none"
restart_service "trojan"
restart_service "trojan@none"

# Remove the script
rm -f /root/cf.sh
