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
EOF

sed -i 's/^#?Storage=.*/Storage=volatile/' "${ROOTFS_DIR}/etc/systemd/journald.conf"
sed -i 's/^#?RuntimeMaxUse=.*/RuntimeMaxUse=50M/' "${ROOTFS_DIR}/etc/systemd/journald.conf"
