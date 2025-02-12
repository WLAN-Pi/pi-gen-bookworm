#!/bin/bash -e

# Installs a wlanpi-system-init service intended for the WLAN Pi Go:
# 1. Performs root filesystem resize
# 2. Configures serial console based on available hardware, reboots if console changes needed
# Install location: wlanpi1-lite/06-sys-conf/02-run.sh

# --- Configure Console and Resize Filesystem on First Boot ---
on_chroot << 'CHEOF'
echo '#!/bin/bash

touch /var/log/wlanpi-system-init.log || {
    echo "Error: Cannot create log file"
    exit 1
}
exec 1>/var/log/wlanpi-system-init.log 2>&1
set -x

echo "=== Starting wlanpi-system-init $(date) ==="

# --- Filesystem resizing ---
root_dev=$(findmnt -vno SOURCE /)

if [ -z "${root_dev}" ]; then
    echo "Error: Could not detect root device"
    exit 1
fi

base_device=$(echo "${root_dev}" | sed "s/p[0-9]*$//")
part_num=$(echo "${root_dev}" | grep -o "[0-9]*$")

if [ -z "${part_num}" ]; then
    echo "Error: Could not determine partition number"
    exit 1
fi

timeout 30 bash -c "parted -s ${base_device} resizepart ${part_num} 100% && partprobe ${base_device} && resize2fs -f ${root_dev}"
if [ $? -ne 0 ]; then
    echo "Error: Resize operation failed or timed out after 30 seconds"
    exit 1
fi

sync
echo "Success: Filesystem resized successfully"

# --- Console configuration ---
if [ ! -f /boot/firmware/cmdline.txt ]; then
    echo "Warning: cmdline.txt not found"
else
    cp /boot/firmware/cmdline.txt /boot/firmware/cmdline.txt.wlanpi-system-init.bak
    if [ -c /dev/serial0 ]; then
        sed -i "s/console=ttyAMA3,115200 /console=serial0,115200 /" /boot/firmware/cmdline.txt
        echo "Success: Console configured for serial0"
    else
        echo "Warning: No supported serial device found"
    fi
fi

# --- MOTD configuration ---

echo "Welcome to WLAN Pi OS. This device is intended for educational, laboratory, and non-commercial testing purposes. WLAN Pi provides no warranty, express or implied. You are solely responsible for complying with applicable laws and regulations." > /etc/motd

echo "=== Completed wlanpi-system-init $(date) ===" ' > /usr/sbin/wlanpi-system-init

chmod +x /usr/sbin/wlanpi-system-init
CHEOF

on_chroot << 'CHEOF'
cat > /etc/systemd/system/wlanpi-system-init.service << 'EOF'
[Unit]
Description=Configure console, motd, and resizefs on first boot
ConditionPathExists=!/var/lib/wlanpi-system-init-service-ran
After=systemd-udev-settle.service local-fs.target
Requires=local-fs.target

[Service]
Type=oneshot
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal
ExecStart=/usr/sbin/wlanpi-system-init
ExecStartPost=/bin/touch /var/lib/wlanpi-system-init-service-ran

[Install]
WantedBy=multi-user.target
EOF

systemctl enable wlanpi-system-init.service
CHEOF
