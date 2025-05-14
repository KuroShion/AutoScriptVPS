#!/bin/bash
# This script is used to set up a wildcard SSL certificate using Cloudflare API
# and issue a certificate for a specific domain.
# It also manages the expiration of various user accounts and services.
# It is designed to be run on a VPS with specific configurations.  

# Define color codes for output
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
# Get the server's public IP of the VPS
MYIP=$(wget -qO- icanhazip.com);

# Check if the VPS is running
echo "Checking"
echo "Checking VPS"

# Section 1: Cleanup expired L2TP VPN users
data=( `cat /var/lib/premium-script/data-user-l2tp | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
    exp=$(grep -w "^### $user" "/var/lib/premium-script/data-user-l2tp" | cut -d ' ' -f 3)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" = "0" ]]; then
        sed -i "/^### $user $exp/d" "/var/lib/premium-script/data-user-l2tp"
        sed -i '/^"'"$user"'" l2tpd/d' /etc/ppp/chap-secrets
        sed -i '/^'"$user"':\$1\$/d' /etc/ipsec.d/passwd
        chmod 600 /etc/ppp/chap-secrets* /etc/ipsec.d/passwd*
    fi
done
# Section 2: Cleanup expired PPTP VPN users
data=( `cat /var/lib/premium-script/data-user-pptp | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
    exp=$(grep -w "^### $user" "/var/lib/premium-script/data-user-pptp" | cut -d ' ' -f 3)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" = "0" ]]; then
        sed -i "/^### $user $exp/d" "/var/lib/premium-script/data-user-pptp"
        sed -i '/^"'"$user"'" pptpd/d' /etc/ppp/chap-secrets
        chmod 600 /etc/ppp/chap-secrets*
    fi
done

# Section 3: Cleanup expired Shadowsocks-libev users
data=( `cat /etc/shadowsocks-libev/akun.conf | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
    exp=$(grep -w "^### $user" "/etc/shadowsocks-libev/akun.conf" | cut -d ' ' -f 3)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" = "0" ]]; then
        sed -i "/^### $user $exp/,/^port_http/d" "/etc/shadowsocks-libev/akun.conf"
        systemctl disable shadowsocks-libev-server@$user-tls.service
        systemctl disable shadowsocks-libev-server@$user-http.service
        systemctl stop shadowsocks-libev-server@$user-tls.service
        systemctl stop shadowsocks-libev-server@$user-http.service
        rm -f "/etc/shadowsocks-libev/$user-tls.json"
        rm -f "/etc/shadowsocks-libev/$user-http.json"
    fi
done

# Section 4: Cleanup expired ShadowsocksR users
data=( `cat /usr/local/shadowsocksr/akun.conf | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
    exp=$(grep -w "^### $user" "/usr/local/shadowsocksr/akun.conf" | cut -d ' ' -f 3)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" = "0" ]]; then
        sed -i "/^### $user $exp/d" "/usr/local/shadowsocksr/akun.conf"
        cd /usr/local/shadowsocksr
        match_del=$(python mujson_mgr.py -d -u "${user}"|grep -w "delete user")
        cd
    fi
done
/etc/init.d/ssrmu restart

# Section 5: Cleanup expired SSTP VPN users
data=( `cat /var/lib/premium-script/data-user-sstp | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
    exp=$(grep -w "^### $user" "/var/lib/premium-script/data-user-sstp" | cut -d ' ' -f 3)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" = "0" ]]; then
        sed -i "/^### $user $exp/d" "/var/lib/premium-script/data-user-sstp"
        sed -i '/^'"$user"'/d' /home/sstp/sstp_account
    fi
done

# Section 6: Cleanup expired Trojan users
data=( `cat /etc/trojan/akun.conf | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
    exp=$(grep -w "^### $user" "/etc/trojan/akun.conf" | cut -d ' ' -f 3)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" = "0" ]]; then
        sed -i "/^### $user $exp/d" "/etc/trojan/akun.conf"
        sed -i '/^,"'"$user"'"$/d' /etc/trojan/config.json
    fi
done
systemctl restart trojan

# Section 7: Cleanup expired WireGuard users
data=( `cat /etc/wireguard/wg0.conf | grep '^### Client' | cut -d ' ' -f 3`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
    exp=$(grep -w "^### Client $user" "/etc/wireguard/wg0.conf" | cut -d ' ' -f 4)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" = "0" ]]; then
        sed -i "/^### Client $user $exp/,/^AllowedIPs/d" /etc/wireguard/wg0.conf
        rm -f "/home/vps/public_html/$user.conf"
    fi
done
systemctl restart wg-quick@wg0

# Section 8: Cleanup expired V2Ray users
data=( `cat /etc/v2ray/config.json | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
    exp=$(grep -w "^### $user" "/etc/v2ray/config.json" | cut -d ' ' -f 3)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" = "0" ]]; then
        sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/config.json
        sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/none.json
        rm -f /etc/v2ray/$user-tls.json /etc/v2ray/$user-none.json
    fi
done
systemctl restart v2ray
systemctl restart v2ray@none

# Section 9: Cleanup expired V2Ray VLESS users
data=( `cat /etc/v2ray/vless.json | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
    exp=$(grep -w "^### $user" "/etc/v2ray/vless.json" | cut -d ' ' -f 3)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" = "0" ]]; then
        sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/vless.json
        sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/vnone.json
    fi
done
systemctl restart v2ray@vless
systemctl restart v2ray@vnone