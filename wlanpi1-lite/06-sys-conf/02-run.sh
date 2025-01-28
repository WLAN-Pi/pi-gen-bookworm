#!/bin/bash -e

# Installs a firstboot service intended for the WLAN Pi Go:
# 1. Performs root filesystem resize
# 2. Configures serial console based on available hardware, reboots if console changes
# Install location: wlanpi1-lite/06-sys-conf/02-run.sh

# --- Configure Console and Resize Filesystem on First Boot ---
on_chroot << 'CHEOF'
echo '#!/bin/bash

touch /var/log/firstboot.log || {
    echo "Error: Cannot create log file"
    exit 1
}
exec 1>/var/log/firstboot.log 2>&1
set -x

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

timeout 30 bash -c "parted -s ${base_device} resizepart ${part_num} 100% && partprobe ${base_device} && resize2fs ${root_dev}"
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
    cp /boot/firmware/cmdline.txt /boot/firmware/cmdline.txt.firstboot.bak
    if [ -c /dev/serial0 ]; then
        sed -i "s/console=ttyAMA3,115200 /console=serial0,115200 /" /boot/firmware/cmdline.txt
        /bin/systemctl --no-block reboot
    else
        echo "Warning: No supported serial device found"
    fi
fi' > /usr/sbin/firstboot-resize

chmod +x /usr/sbin/firstboot-resize
CHEOF

on_chroot << 'CHEOF'
cat > /etc/systemd/system/firstboot.service << 'EOF'
[Unit]
Description=Configure Console and Resize Filesystem on First Boot
ConditionFirstBoot=yes
After=systemd-udev-settle.service local-fs.target
Requires=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/firstboot-resize

[Install]
WantedBy=multi-user.target
EOF

systemctl enable firstboot.service
CHEOF
