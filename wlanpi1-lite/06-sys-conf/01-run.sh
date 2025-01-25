#!/bin/bash -e

on_chroot << EOF

CONFIG="/boot/firmware/config.txt"

# Section to modify
SECTION="cm4"

# Lines to add if missing
LINES_TO_ADD=(
    "dtoverlay=disable-wifi"
    "dtoverlay=disable-bt"
    "dtoverlay=uart3"
    "dtoverlay=uart2"
    "dtoverlay=uart0"
    "gpio=27=op,dh"
    "dtoverlay=max3421-hcd"
)

# Check if the section exists
if grep -q "^\[\$SECTION\]" "\$CONFIG"; then

    echo "[\$SECTION] section found in \$CONFIG. Checking for missing lines."

    for LINE in "\${LINES_TO_ADD[@]}"; do
        # Check if the line exists in the section
        if ! sed -n "/^\[\$SECTION\]/,/^\[/p" "\$CONFIG" | grep -q "\$LINE"; then
            echo "Adding '\$LINE' to [\$SECTION] section in \$CONFIG"
            sed -i "/^\[\$SECTION\]/a \$LINE" "\$CONFIG"
        else
            echo "'\$LINE' already exists in [\$SECTION] section. Skipping."
        fi
    done

else
    echo "No [\$SECTION] section found in \$CONFIG. Skipping addition of lines."
fi

EOF


#on_chroot << EOF

#CMDLINE="/boot/firmware/cmdline.txt"

# The desired new content for cmdline.txt
#NEW_CMDLINE="console=ttyAMA3,115200 console=tty1 root=ROOTDEV rootfstype=ext4 fsck.repair=yes rootwait quiet init=/usr/lib/raspberrypi-sys-mods/firstboot cfg80211.ieee80211_regdom=US"

# Replace the entire line in cmdline.txt
#echo "\$NEW_CMDLINE" > "\$CMDLINE"

# Feedback to the user
#echo "Replaced the contents of \$CMDLINE with the new line."

#touch /boot/firmware/cmdline.txt

#EOF
