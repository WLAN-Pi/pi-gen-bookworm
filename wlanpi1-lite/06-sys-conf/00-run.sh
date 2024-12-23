#!/bin/bash -e

# Enable systemd-networkd
on_chroot <<CHEOF

# Enable systemd-networkd
systemctl enable systemd-networkd.service
systemctl start systemd-networkd.service

# Create systemd network configuration for eth0 (DHCP)
cat <<EOF > /etc/systemd/network/10-eth0.network
[Match]
Name=eth0

[Network]
DHCP=yes
EOF

# Create systemd network configuration for wlan0 (DHCP)
cat <<EOF > /etc/systemd/network/10-wlan0.network
[Match]
Name=wlan0

[Network]
DHCP=yes
EOF

# Reload systemd-networkd to apply the configuration
systemctl restart systemd-networkd.service
CHEOF

