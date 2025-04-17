#!/bin/bash -e

install -v -d "${ROOTFS_DIR}/usr/local/sbin"

install -v -m 755 files/go-hw-machine-id.sh "${ROOTFS_DIR}/usr/local/sbin/"
install -v -m 755 files/go-serial2json.sh "${ROOTFS_DIR}/usr/local/sbin/"
install -v -m 755 files/go-device-info-decoder.sh "${ROOTFS_DIR}/usr/local/sbin/"

install -v -m 644 files/go-hw-machine-id.service "${ROOTFS_DIR}/etc/systemd/system/"

on_chroot << EOF
# Force machine-id empty to trigger systemd first-boot behavior
echo -n > /etc/machine-id
chmod 444 /etc/machine-id

# Enable service
systemctl enable go-hw-machine-id.service
EOF