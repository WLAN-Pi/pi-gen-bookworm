#!/bin/bash

set -e 

if ! command -v ufw >/dev/null 2>&1; then
    echo "ufw not found ..."
fi

ufw limit ssh
# ufw --force enable
raspi-config nonint do_wifi_country US

echo '#!/bin/sh
echo "Welcome to WLAN Pi OS. This device is intended for educational, laboratory, and non-commercial testing purposes. WLAN Pi provides ABSOLUTELY NO WARRANTY. You are solely responsible for complying with applicable laws and regulations."' > /etc/update-motd.d/20-wlanpi-legal
chmod +x /etc/update-motd.d/20-wlanpi-legal

exit 0
