#!/bin/bash -e

# Installs a wlanpi-system-init service:
# Install location: wlanpi1-lite/06-sys-conf/02-run.sh

on_chroot << 'CHEOF'
echo '#!/bin/bash

touch /var/log/wlanpi-system-init.log || {
    echo "Error: Cannot create log file"
    exit 1
}
exec 1>/var/log/wlanpi-system-init.log 2>&1
set -x

echo "=== Starting wlanpi-system-init $(date) ==="

# --- MOTD configuration ---

echo "Welcome to WLAN Pi OS. This device is intended for educational, laboratory, and non-commercial testing purposes. WLAN Pi provides no warranty, express or implied. You are solely responsible for complying with applicable laws and regulations." > /etc/motd

echo "=== Completed wlanpi-system-init $(date) ===" ' > /usr/sbin/wlanpi-system-init

chmod +x /usr/local/sbin/wlanpi-system-init
CHEOF

on_chroot << 'CHEOF'
cat > /etc/systemd/system/wlanpi-system-init.service << 'EOF'
[Unit]
Description=Configure motd on first boot
ConditionPathExists=!/var/lib/wlanpi-system-init-service-ran
After=systemd-udev-settle.service local-fs.target
Requires=local-fs.target

[Service]
Type=oneshot
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal
ExecStart=/usr/local/sbin/wlanpi-system-init
ExecStartPost=/bin/touch /var/lib/wlanpi-system-init-service-ran

[Install]
WantedBy=multi-user.target
EOF

systemctl enable wlanpi-system-init.service
CHEOF
