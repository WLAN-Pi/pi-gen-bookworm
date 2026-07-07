#!/bin/bash -e

install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi

if [ -n "${FIRST_USER_PASS}" ]; then
	echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
fi
echo "root:root" | chpasswd

# Add user to adm group for journalctl access
usermod -aG adm ${FIRST_USER_NAME}

# Load i2c module at boot
echo "i2c-dev" >> /etc/modules
EOF

