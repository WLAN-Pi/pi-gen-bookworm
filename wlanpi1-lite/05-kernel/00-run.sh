#!/bin/bash -e

# /boot/firmware exists from 00-boot-files, but overlays/ is created by the
# kernel package postinst. mkdir so the dtbo copy works even though we no
# longer apt-install the kernel in 00-packages (that would pull 7.1.10).
mkdir -p "${ROOTFS_DIR}/boot/firmware/overlays"
install -m 644 files/max3421-hcd.dtbo "${ROOTFS_DIR}/boot/firmware/overlays/"

# Pin 6.12.98-v8-wlanpi+-20260730 (wlanpi-kernel PR #31) from GitHub.
# Encoded URL: '+' in the tag/filename must be %2B.
# Hold the package so later stages (e.g. 08-install-wlanpi-packages) cannot
# apt-upgrade it to 7.1.10 from packagecloud.
KERNEL_DEB_URL="https://github.com/WLAN-Pi/wlanpi-kernel/releases/download/6.12.98-v8-wlanpi%2B-20260730/wlanpi-kernel-bookworm-v8_6.12.98-v8-wlanpi%2B-20260730_arm64.deb"

on_chroot <<CHEOF
	wget -O /tmp/wlanpi-kernel.deb "${KERNEL_DEB_URL}"
	dpkg -i /tmp/wlanpi-kernel.deb
	apt-mark hold wlanpi-kernel-bookworm-v8
	rm -f /tmp/wlanpi-kernel.deb
CHEOF
