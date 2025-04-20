#!/bin/bash -e

install -v -m 755 files/boot-info "${ROOTFS_DIR}/usr/local/sbin/"
install -v -m 755 files/commit-current-partition "${ROOTFS_DIR}/usr/local/sbin/"
install -v -m 755 files/switch-partition "${ROOTFS_DIR}/usr/local/sbin/"
install -v -m 755 files/update-inactive-partition "${ROOTFS_DIR}/usr/local/sbin/"
