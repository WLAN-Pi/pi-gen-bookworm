#!/bin/bash -e

on_chroot << EOF
# Set tshark/wireshark preseed
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections

# Install tshark
apt-get install -y tshark

apt-get install -y --no-install-recommends flent
EOF
