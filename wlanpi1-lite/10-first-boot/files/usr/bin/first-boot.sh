#!/bin/bash

set -e 

raspi-config nonint do_wifi_country US || echo "WARNING: failed to set country code"

echo '#!/bin/sh
echo "Welcome to WLAN Pi OS. This device is intended for educational, laboratory, and non-commercial testing purposes. WLAN Pi provides ABSOLUTELY NO WARRANTY. You are solely responsible for complying with applicable laws and regulations."' > /etc/update-motd.d/20-wlanpi-legal
chmod +x /etc/update-motd.d/20-wlanpi-legal

if ! command -v ufw >/dev/null 2>&1; then
    echo "ufw not found ..."
else
    # ensure UFW is configured
    ufw default deny incoming
    ufw default allow outgoing
    
    ssh_rule_added=false

    # SSH
    ufw allow 22/tcp
    
    # oscium-spectrum
    ufw allow 3264/tcp
    ufw allow 3264/udp

    # oscium-capture
    ufw allow 6174/tcp
    ufw allow 6174/udp

    # DHCP server
    ufw allow 67/udp

    # ephemeral/avahi-related port
    ufw allow 36872/udp

    # mDNS (IPv4 multicast)
    ufw allow proto udp from 224.0.0.0/4 to any port 5353

    # mDNS (IPv6 link-local multicast)
    ufw allow proto udp from fe80::/10 to any port 5353

    ufw logging on

    if ! ufw status verbose | grep -q "22/tcp.*ALLOW"; then
        echo "WARNING: SSH rule not properly added ... retrying ..."
        ufw delete allow 22/tcp 2>/dev/null || true
        if ufw allow 22/tcp; then
            ssh_rule_added=true
        fi
    else
        ssh_rule_added=true
    fi

    if [[ "$ssh_rule_added" == true ]]; then
        ufw --force enable
        echo "ufw enabled after force ..."
    else
        echo "WARNING: SSH not in firewall rules. ufw not enabled to prevent lockout ..."
        exit 1
    fi
fi

exit 0
