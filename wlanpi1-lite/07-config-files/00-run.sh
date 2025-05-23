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
	wget -O /tmp/wireless-regdb.deb http://ftp.us.debian.org/debian/pool/main/w/wireless-regdb/wireless-regdb_2025.02.20-1_all.deb
	dpkg -i /tmp/wireless-regdb.deb
	rm -f /tmp/wireless-regdb.deb
	update-alternatives --set regulatory.db /lib/firmware/regulatory.db-upstream

	# Automatically reboot after 5 seconds if a kernel panic occurs
	echo "kernel.panic = 5" >> /etc/sysctl.conf
CHEOF

cat > "${ROOTFS_DIR}/tmp/update-os-release.sh" << EOF
#!/bin/bash
echo "Debug: WLANPI_VERSION=\${WLANPI_VERSION}"
echo "Debug: WLANPI_CODENAME=\${WLANPI_CODENAME}"
echo "Debug: WLANPI_HOME_URL=\${WLANPI_HOME_URL}"
echo "Debug: WLANPI_SUPPORT_URL=\${WLANPI_SUPPORT_URL}"
echo "Debug: WLANPI_BUG_REPORT_URL=\${WLANPI_BUG_REPORT_URL}"

echo "=== Setting WLAN Pi version information ==="
echo "VERSION=${WLANPI_VERSION}" > /etc/wlanpi-release
chmod 644 /etc/wlanpi-release 

echo "=== Updating /etc/os-release release information ==="
echo "Original /etc/os-release content:"
cat /etc/os-release

# Update os-release file with WLAN Pi specific information
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"WLAN Pi GNU\/Linux 12 (${WLANPI_CODENAME})\"/" /etc/os-release
sed -i 's/^NAME=.*/NAME="WLAN Pi GNU\/Linux"/' /etc/os-release 
sed -i 's|^HOME_URL=.*|HOME_URL="${WLANPI_HOME_URL}"|' /etc/os-release
sed -i 's|^SUPPORT_URL=.*|SUPPORT_URL="${WLANPI_SUPPORT_URL}"|' /etc/os-release
sed -i 's|^BUG_REPORT_URL=.*|BUG_REPORT_URL="${WLANPI_BUG_REPORT_URL}"|' /etc/os-release
sed -i 's/^VERSION_CODENAME=.*/VERSION_CODENAME=${WLANPI_CODENAME}/' /etc/os-release

echo "Updated /etc/os-release content:"
cat /etc/os-release

echo "=== /etc/os-release update complete ==="
EOF

chmod +x "${ROOTFS_DIR}/tmp/update-os-release.sh"

on_chroot << EOF
WLANPI_VERSION="${WLANPI_VERSION}" \
WLANPI_CODENAME="${WLANPI_CODENAME}" \
WLANPI_HOME_URL="${WLANPI_HOME_URL}" \
WLANPI_SUPPORT_URL="${WLANPI_SUPPORT_URL}" \
WLANPI_BUG_REPORT_URL="${WLANPI_BUG_REPORT_URL}" \
/tmp/update-os-release.sh 
EOF

rm -f "${ROOTFS_DIR}/tmp/update-os-release.sh"

# Add our custom sudoers file
copy_overlay /etc/sudoers.d/wlanpidump -o root -g root -m 440

# Add a default wpa_supplicant configuration with the control interface disabled
copy_overlay /etc/wpa_supplicant/wpa_supplicant.conf -o root -g root -m 600

# Copy config file: avahi-daemon
copy_overlay /etc/avahi/avahi-daemon.conf -o root -g root -m 644

# Copy config files
install -m 644 files/.vimrc "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.vimrc"
install -m 644 files/.tmux.conf "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.tmux.conf"
install -m 644 files/.bash_aliases "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bash_aliases"
install -m 644 files/.vimrc "${ROOTFS_DIR}/root/.vimrc"
install -m 644 files/.tmux.conf "${ROOTFS_DIR}/root/.tmux.conf"

# Set term for ghostty
# Add fzf key bindings and completion to .bashrc
cat >> "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc" << 'EOF'

# Enable fzf key bindings and completion if available
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
        source /usr/share/doc/fzf/examples/key-bindings.bash
fi

if [ -f /usr/share/doc/fzf/examples/completion.bash ]; then
        source /usr/share/doc/fzf/examples/completion.bash
fi

if [[ "$TERM" == "xterm-ghostty" ]]; then
    export TERM=xterm-256color
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
fi
EOF

# Stage tmux and vim config for both user and root for consistent experience
on_chroot << EOF
# Create necessary directories for both users
mkdir -p /home/${FIRST_USER_NAME}/.vim/undodir
mkdir -p /root/.vim/undodir

# Create empty viminfo files
touch /home/${FIRST_USER_NAME}/.vim/viminfo
touch /root/.vim/viminfo

# Set ownership for regular user
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/.vimrc
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/.tmux.conf
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/.vim
chown -R ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/.bash_aliases

# Set permissions for user
chmod 600 /home/${FIRST_USER_NAME}/.vim/viminfo
chmod 700 /home/${FIRST_USER_NAME}/.vim/undodir

# Set permissions for root
chmod 600 /root/.vim/viminfo
chmod 700 /root/.vim/undodir
EOF