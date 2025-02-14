#!/bin/bash -e

on_chroot << EOF
# TODO remove this and migrate regulatory out of pi-gen
wlanpi-reg-domain set US
EOF
