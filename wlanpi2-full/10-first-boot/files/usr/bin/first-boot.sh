#!/bin/bash

set -e 

if ! command -v ufw >/dev/null 2>&1; then
    echo "ufw not found ..."
fi

ufw limit ssh
# ufw --force enable
raspi-config nonint do_wifi_country US

exit 0
