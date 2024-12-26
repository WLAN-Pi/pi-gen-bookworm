#!/bin/bash -e

on_chroot << EOF

CONFIG="/boot/firmware/config.txt"

# Only proceed if [cm4] section exists
if grep -q '^\[cm4\]' "\$CONFIG"; then
    
    # Check if gpio=27=op,dh is already in the [cm4] section
    if ! sed -n '/^\[cm4\]/,/^\[/p' "\$CONFIG" | grep -q 'gpio=27=op,dh'; then
        echo "Adding 'gpio=27=op,dh' to [cm4] section in \$CONFIG"
        # Insert right after the [cm4] line 
        sed -i '/^\[cm4\]/a gpio=27=op,dh' "\$CONFIG"
    else
        echo "'gpio=27=op,dh' already found in the [cm4] section. No change."
    fi

else
    echo "No [cm4] section found in \$CONFIG. Skipping insertion."
fi

EOF
