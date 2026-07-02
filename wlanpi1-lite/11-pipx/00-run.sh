#!/bin/bash -e

on_chroot << EOF
export PIPX_HOME=/opt/wlanpi/pipx
export PIPX_BIN_DIR=/opt/wlanpi/pipx/bin
mkdir -p "\${PIPX_HOME}" "\${PIPX_BIN_DIR}"
PIPX_HOME="\${PIPX_HOME}" PIPX_BIN_DIR="\${PIPX_BIN_DIR}" pipx install speedtest-cli
EOF

cat >> "${ROOTFS_DIR}/etc/profile.d/wlanpi-pipx.sh" << 'EOF'
export PATH="/opt/wlanpi/pipx/bin:${PATH}"
EOF
