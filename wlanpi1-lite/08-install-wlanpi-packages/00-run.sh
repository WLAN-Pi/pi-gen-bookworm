#!/bin/bash -e

# Install local Trixie-compatible wlanpi-core build before apt resolves dependents
cp /home/jakesnyder/source/wlanpi-core/wlanpi-core_2.1.11-1~pr131_arm64.deb "${ROOTFS_DIR}/tmp/"
cp /home/jakesnyder/source/wlanpi-common/wlanpi-common_1.1.43+trixie3_arm64.deb "${ROOTFS_DIR}/tmp/"
cp /home/jakesnyder/source/wlanpi-webui/wlanpi-webui_1.4.0-2_arm64.deb "${ROOTFS_DIR}/tmp/"
on_chroot << EOF
apt-get install -y --reinstall --allow-downgrades /tmp/wlanpi-core_2.1.11-1~pr131_arm64.deb
apt-get install -y --reinstall --allow-downgrades /tmp/wlanpi-common_1.1.43+trixie3_arm64.deb
apt-get install -y --reinstall --allow-downgrades /tmp/wlanpi-webui_1.4.0-2_arm64.deb
rm -f /tmp/wlanpi-core_2.1.11-1~pr131_arm64.deb /tmp/wlanpi-common_1.1.43+trixie3_arm64.deb /tmp/wlanpi-webui_1.4.0-2_arm64.deb
EOF

on_chroot << EOF
echo "=== removing wlanpi-stats from profile.d ==="
rm -f /etc/profile.d/wlanpi-stats.sh
echo "=== finish removing wlanpi-stats from profile.d ==="
EOF
