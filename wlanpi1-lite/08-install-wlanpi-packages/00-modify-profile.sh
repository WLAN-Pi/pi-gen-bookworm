#!/bin/bash -e

on_chroot << EOF
echo "=== removing wlanpi-stats from profile ==="
rm /etc/profile.d/wlanpi-stats.sh
echo "=== finish removing wlanpi-stats from profile ==="
EOF
