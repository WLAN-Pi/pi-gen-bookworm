#!/bin/bash

set -e 

if ! command -v ufw >/dev/null 2>&1; then
    echo "ufw not found ..."
fi

ufw limit ssh
ufw --force enable
wlanpi-reg-domain set US

exit 0
