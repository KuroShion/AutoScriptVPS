#!/bin/bash

# Ensure the script is run as root
if [ "${EUID}" -ne 0 ]; then
    echo "You need to run this script as root to install correctly"
    exit 1
fi

# Check for unsupported virtualization
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ is not supported"
    exit 1
fi

# Define colors for output
RED='\e[1;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'
based="\e[39m"
danger="\e[91m"
warning="\e[93m"
success="\e[92m"

# Rollback log file
ROLLBACK_LOG="/tmp/rollback.log"

# Function to log changes for rollback
log_change() {
    echo "$1" >> "$ROLLBACK_LOG"
}

# Function to perform rollback
rollback() {
    echo -e "\n${RED}An error occurred. Rolling back changes...${NC}"
    if [ -f "$ROLLBACK_LOG" ]; then
        while read -r line; do
            eval "$line"
        done < "$ROLLBACK_LOG"
        echo -e "${GREEN}Rollback completed.${NC}"
    else
        echo -e "${RED}No rollback log found. Nothing to rollback.${NC}"
    fi
    rm -f "$ROLLBACK_LOG"
    exit 1
}

# Trap errors to trigger rollback
trap rollback ERR

# Start with a clean rollback log
rm -f "$ROLLBACK_LOG"

# Check if sha256sum is available
if ! command -v sha256sum &> /dev/null; then
    echo -e "\n[${warning}Permission$based] > sha256sum command not found. Installing it now..."
    apt-get update && apt-get install -y coreutils || {
        echo -e "\n[${danger}ERROR$based] > Failed to install sha256sum. Please install it manually and rerun the script."
        exit 1
    }
    echo -e "\n[${success}SUCCESS$based] > sha256sum installed successfully. Restarting password verification..."
    exec "$0" # Restart the script
fi

# Password verification with confirmation
EXPECTED_HASH="d24abe59158f4d5118eec6f063c5b2e67844643d0d2ce9235728f79fb1de8021" # Hash of "KuroShion"
echo -e "\n[${warning}Permission$based] > Insert Password :"
read -r -s Password
echo -e "\n[${warning}Permission$based] > Confirm Password :"
read -r -s PasswordConfirm
if [ "$Password" != "$PasswordConfirm" ]; then
    echo -e "\n[${danger}ERROR$based] > Passwords do not match"
    exit 1
fi
ENTERED_HASH=$(echo -n "$Password" | sha256sum | awk '{print $1}')
if [ "$ENTERED_HASH" == "$EXPECTED_HASH" ]; then
    echo -e "\n[${success}SUCCESS$based] > Password correct"
    echo -e "[${warning}Output$based]  > Allowed Installation :)"
else
    echo -e "\n[${danger}ERROR$based]  > Password Incorrect"
    echo -e "[${danger}ERROR$based]  > Please contact the admin"
    echo -e "[${danger}ERROR$based]  > https://t.me/KuroShion"
    echo -e "[${warning}Output$based] > Abort Installation  :'("
    exit 1
fi

# Check if the script is already installed
if [ -f "/etc/v2ray/domain" ]; then
    echo "Script Already Installed"
    exit 0
fi

# Create necessary directories and log rollback commands
mkdir -p /var/lib/premium-script
log_change "rm -rf /var/lib/premium-script"

# Add IP configuration and log rollback command
echo "IP=" >> /var/lib/premium-script/ipvps.conf
log_change "sed -i '/IP=/d' /var/lib/premium-script/ipvps.conf"

# Download and execute scripts, logging rollback commands
wget https://raw.githubusercontent.com/KuroShion/AutoScriptVPS/main/cf.sh && chmod +x cf.sh && ./cf.sh
log_change "rm -f cf.sh"

wget https://raw.githubusercontent.com/KuroShion/AutoScriptVPS/main/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh || {
    echo "Error: Failed to download or execute ssh-vpn.sh. Please check your internet connection or the URL."
    exit 1
}
log_change "rm -f ssh-vpn.sh"

# Install additional tools and log rollback commands
apt-get install -y figlet || {
    echo "Error: Failed to install figlet"
    exit 1
}
log_change "apt-get remove -y figlet"

apt-get install -y ruby || {
    echo "Error: Failed to install ruby"
    exit 1
}
log_change "apt-get remove -y ruby"

gem install lolcat || {
    echo "Error: Failed to install lolcat"
    exit 1
}
log_change "gem uninstall lolcat"

# Create systemd service and log rollback commands
cat <<EOF> /etc/systemd/system/autosett.service
[Unit]
Description=autosetting
Documentation=https://www.abidz.ga

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/set.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
log_change "rm -f /etc/systemd/system/autosett.service"

systemctl daemon-reload
systemctl enable autosett || {
    echo "Error: Failed to enable autosett service"
    exit 1
}
log_change "systemctl disable autosett"

# Hostname setting with availability check
if ! command -v hostnamectl &> /dev/null; then
    echo "Error: hostnamectl command not found. Skipping hostname configuration."
else
    hostnamectl set-hostname SETUP-BY-EVOTEAM || {
        echo "Error: Failed to set hostname. Please ensure the hostnamectl command is available."
        exit 1
    }
fi

# Final cleanup and success message
figlet -c Instalation Success | lolcat

echo "Installation is complete. A reboot is required to apply the changes."
while true; do
    read -p "Do you want to reboot now? (y/n): " REBOOT_CONFIRMATION
    case "$REBOOT_CONFIRMATION" in
        [Yy]* ) 
            echo "Rebooting now..."
            rm -f install.sh
            rm -f "$ROLLBACK_LOG"
            reboot
            break
            ;;
        [Nn]* ) 
            echo "Reboot canceled. Please reboot manually to apply the changes."
            rm -f install.sh
            rm -f "$ROLLBACK_LOG"
            break
            ;;
        * ) echo "Please answer y or n." ;;
    esac
done
