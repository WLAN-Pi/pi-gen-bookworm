#!/bin/bash -e

on_chroot <<CHEOF
	# Set retry for dhclient
	if grep -q -E "^#?retry " /etc/dhcp/dhclient.conf; then
		sed -i 's/^#\?retry .*/retry 600;/' /etc/dhcp/dhclient.conf
	else
		echo "retry 600;" >> /etc/dhcp/dhclient.conf
	fi

	if grep -A6 "^[[:space:]]*request" /etc/dhcp/dhclient.conf | grep -q "rfc3442-classless-static-routes" && ! grep -q "#.*rfc3442-classless-static-routes" /etc/dhcp/dhclient.conf; then
		sed -i '
		/^[[:space:]]*request/{
			:a
			N
			/;$/!ba
			s/,[[:space:]]*rfc3442-classless-static-routes//
			s/;$/;\n        # rfc3442-classless-static-routes/
		}' /etc/dhcp/dhclient.conf
	fi

	# Send hardware MAC address to DHCP server
	if grep -q -E "^#?send dhcp-client-identifier " /etc/dhcp/dhclient.conf; then
		sed -i 's/^#\?send dhcp-client-identifier .*/send dhcp-client-identifier = hardware;/' /etc/dhcp/dhclient.conf
	else
		echo "send dhcp-client-identifier = hardware;" >> /etc/dhcp/dhclient.conf
	fi

	# Change default systemd boot target from graphical.target to multi-user.target
	systemctl set-default multi-user.target

	# Configure arp_ignore: network/arp
	echo "net.ipv4.conf.eth0.arp_ignore = 1" >> /etc/sysctl.conf

	# Fetch current version of the pci. ids file
	update-pciids

	# Install wireless-regdb
	wget -O /tmp/wireless-regdb_2024.10.07-2_all.deb http://ftp.us.debian.org/debian/pool/main/w/wireless-regdb/wireless-regdb_2024.10.07-2_all.deb
	dpkg -i /tmp/wireless-regdb_2024.10.07-2_all.deb
	rm -f /tmp/wireless-regdb_2024.10.07-2_all.deb
	update-alternatives --set regulatory.db /lib/firmware/regulatory.db-upstream

	# Automatically reboot after 5 seconds if a kernel panic occurs
	echo "kernel.panic = 5" >> /etc/sysctl.conf
CHEOF

# Set WLAN Pi image version
copy_overlay /etc/wlanpi-release -o root -g root -m 644

# Add our custom sudoers file
copy_overlay /etc/sudoers.d/wlanpidump -o root -g root -m 440

# Add a default wpa_supplicant configuration with the control interface disabled
copy_overlay /etc/wpa_supplicant/wpa_supplicant.conf -o root -g root -m 600

# Copy config file: avahi-daemon
copy_overlay /etc/avahi/avahi-daemon.conf -o root -g root -m 644
