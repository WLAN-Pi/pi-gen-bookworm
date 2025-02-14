#!/bin/bash -e

on_chroot << EOF
# Set tshark/wireshark preseed
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections

# Install tshark
apt install -y tshark

apt install -y netperf fping irtt
apt install -y --no-install-recommends flent
EOF
