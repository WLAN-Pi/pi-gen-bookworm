#!/bin/bash -e

# Set WLAN Pi image version
copy_overlay /etc/wlanpi-release -o root -g root -m 644

# Add our custom sudoers file
copy_overlay /etc/sudoers.d/wlanpidump -o root -g root -m 440