#!/bin/bash -e

# Ensure curl is installed in the chroot environment
on_chroot <<CHEOF
        echo "Installing curl"
        apt update
        apt install -y curl
CHEOF

# Add the repositories
on_chroot <<CHEOF
        echo "Add packagecloud wlanpi/main repository"
        curl -s https://packagecloud.io/install/repositories/wlanpi/main/script.deb.sh | bash

        echo "Add packagecloud wlanpi/dev repository"
        curl -s https://packagecloud.io/install/repositories/wlanpi/dev/script.deb.sh | bash

        echo "Running apt update"
        apt update
CHEOF
