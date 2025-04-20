#!/bin/bash -e

install -v -m 755 files/commit_current_partition "${ROOTFS_DIR}/usr/local/sbin/"
install -v -m 755 files/go-serial2json.sh "${ROOTFS_DIR}/usr/local/sbin/"
install -v -m 755 files/go-device-info-decoder.sh "${ROOTFS_DIR}/usr/local/sbin/"
