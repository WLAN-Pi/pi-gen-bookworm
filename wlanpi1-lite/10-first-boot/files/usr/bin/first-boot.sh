#!/bin/bash

set -e 

if ! command -v ufw >/dev/null 2>&1; then
    echo "ufw not found ..."
else
    ufw --force reset

    ufw default deny incoming
    ufw default allow outgoing

    ufw allow 22/tcp

    # oscium-spectrum
    ufw allow 3264/tcp
    ufw allow 3264/udp

    # oscium-capture
    ufw allow 6174/tcp
    ufw allow 6174/udp

    # DHCP server
    ufw allow 67/udp

    # Ephemeral/avahi-related port
    ufw allow 36872/udp

    # mDNS (IPv4 multicast)
    ufw allow proto udp from 224.0.0.0/4 to any port 5353

    # mDNS (IPv6 link-local multicast)
    ufw allow proto udp from fe80::/10 to any port 5353

    # web access and WLAN Pi API
    ufw allow 80/tcp      # HTTP
    ufw allow 443/tcp     # HTTPS
    ufw allow 8081/tcp    # Alt web UI
    ufw allow 31415/tcp   # WLAN Pi API

    ufw logging on
    ufw --force enable
fi

raspi-config nonint do_wifi_country US

echo '#!/bin/sh
echo "Welcome to WLAN Pi OS. This device is intended for educational, laboratory, and non-commercial testing purposes. WLAN Pi provides ABSOLUTELY NO WARRANTY. You are solely responsible for complying with applicable laws and regulations."' > /etc/update-motd.d/20-wlanpi-legal
chmod +x /etc/update-motd.d/20-wlanpi-legal

exit 0
