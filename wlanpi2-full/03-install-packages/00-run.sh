#!/bin/bash -e

on_chroot << EOF
echo "=== tshark install ==="
# Set tshark/wireshark preseed
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections

# Install tshark
apt install -y tshark 
echo "=== tshark done ==="

echo "=== netperf, fping, irtt install ==="
apt install -y netperf fping irtt
apt install -y --no-install-recommends flent
echo "=== netperf, fping, irtt done ==="
EOF
