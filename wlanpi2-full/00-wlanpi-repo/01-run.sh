#!/bin/bash -e

# Ensure curl is installed in the chroot environment
on_chroot <<CHEOF
	echo "Installing curl"
	apt update
	apt install -y curl
CHEOF

# Prefer trixie-built packages over the bookworm fallback whenever both exist
install -m 644 files/99-wlanpi-bookworm-fallback "${ROOTFS_DIR}/etc/apt/preferences.d/"

# Add the repositories. packagecloud's install script always writes
# /etc/apt/sources.list.d/wlanpi_<repo>.list, so the bookworm fallback run
# must be renamed aside before the trixie run or one overwrites the other.
on_chroot <<CHEOF
	echo "Add packagecloud wlanpi/main bookworm fallback (for packages not yet published for trixie)"
	curl -s https://packagecloud.io/install/repositories/wlanpi/main/script.deb.sh | os=debian dist=bookworm bash
	mv /etc/apt/sources.list.d/wlanpi_main.list /etc/apt/sources.list.d/wlanpi_main_bookworm.list
	echo "Add packagecloud wlanpi/main repository"
	curl -s https://packagecloud.io/install/repositories/wlanpi/main/script.deb.sh | bash

	if [ "${INCLUDE_PACKAGECLOUD_DEV}" = "1" ]; then
		echo "Add packagecloud wlanpi/dev bookworm fallback"
		curl -s https://packagecloud.io/install/repositories/wlanpi/dev/script.deb.sh | os=debian dist=bookworm bash
		mv /etc/apt/sources.list.d/wlanpi_dev.list /etc/apt/sources.list.d/wlanpi_dev_bookworm.list
		echo "Add packagecloud wlanpi/dev repository"
		curl -s https://packagecloud.io/install/repositories/wlanpi/dev/script.deb.sh | bash
	else
		echo "Skipping add packagecloud wlanpi/dev repository - see GitHub Actions workflow inputs"
	fi

	echo "Running apt update"
	apt update
CHEOF
