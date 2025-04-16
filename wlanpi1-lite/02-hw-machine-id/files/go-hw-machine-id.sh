#!/bin/bash
#
# go-hw-machine-id.sh - Set machine-id from Go hardware serial number
#
# 1. Reads serial number from /dev/ttyAMA0
# 2. Stores base64 encoded serial number at /home/.device-info/serialnumber
# 3. Sets the SHA-256 hash of the raw serial number at /etc/machine-id
#
# Version: v1.0.0
# Author: Josh Schmelzle
# License: BSD-3

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: need root to run ..."
    exit 1
fi

LOG_FILE="/var/log/go-hw-id-encoder.log"
SERIAL_DEVICE="/dev/ttyAMA0"
DEVICE_INFO_DIR="/home/.device-info"
SERIAL_FILE="${DEVICE_INFO_DIR}/serialnumber"
PRODUCT_FILE="${DEVICE_INFO_DIR}/productid"
TIMEOUT=2

log() {
    echo "$(date -Iseconds): $1" | tee -a "$LOG_FILE"
}

cleanup() {
    if [ -e /proc/$$/fd/3 ]; then
        exec 3<&-
    fi
    exit "${1:-0}"
}

set_immutable() {
    local file="$1"
    if ! chattr +i "$file" 2>/dev/null; then
        log "WARNING: Could not set $file as immutable (filesystem may not support chattr)"
    else
        log "Set $file as immutable (requires chattr -i to modify in future)"
    fi
}

log "Starting go hardware machine-id encoder ..."

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$DEVICE_INFO_DIR"
chmod 750 "$DEVICE_INFO_DIR"

if [ -s "$SERIAL_FILE" ]; then
    log "Serial number file already exists, using existing serial ..."
    SERIAL_NUMBER=$(base64 -d "$SERIAL_FILE" 2>/dev/null || echo "")

    if [ -z "$SERIAL_NUMBER" ]; then
        log "ERROR: failed to decode existing serial number, will try to read from hardware ..."
    fi
fi

if [ -z "$SERIAL_NUMBER" ]; then
    if [ ! -c "$SERIAL_DEVICE" ]; then
        log "ERROR: Serial device $SERIAL_DEVICE not found ..."
        log "Will generate a random machine-id instead ..."
        systemd-machine-id-setup
        cleanup 1
    fi

    log "Reading serial number from $SERIAL_DEVICE ..."

    if ! stty -F "$SERIAL_DEVICE" 115200 -icrnl -ixon -ixoff -opost -isig -icanon -echo 2>/dev/null; then
        echo "Error: Failed to configure serial port $SERIAL_DEVICE"
        cleanup 1
    fi

    log "Opening serial device for reading ..."

    if ! exec 3< "$SERIAL_DEVICE"; then
        log "ERROR: Failed to open serial device for reading"
        cleanup 1
    fi

    line=""
    if ! line=$(timeout "$TIMEOUT" cat <&3 | grep -v "^$" | head -n 1); then
        log "ERROR: Failed to read from serial device"
        cleanup 1
    fi

    if [ -z "$line" ]; then
        log "ERROR: No data received from serial port ..."
        log "Will generate a random machine-id instead ..."
        systemd-machine-id-setup
        cleanup 1
    fi

    IFS=',' read -r product version candidate hardware error tested rfuA rfuB timeSinceStart usbVoltage rfuC vBatt serial <<< "$line"
    if [[ -n "$product" ]]; then
        serial=$(echo "$serial" | tr -d '\r\n')
        log "Parsed device data: product=$product, version=$version, serial=$serial"
    else
        log "ERROR: No data received from serial port ..."
        log "Will generate a random machine-id instead ..."
        systemd-machine-id-setup
        cleanup 1
    fi

    SERIAL_NUMBER=$serial
    PRODUCT_ID=$product

    if [ -z "$SERIAL_NUMBER" ]; then
        log "ERROR: Failed to extract serial number from data ..."
        log "Will generate a random machine-id instead ..."
        systemd-machine-id-setup
        cleanup 1
    fi

    log "Extracted serial number: $SERIAL_NUMBER ..."

    echo -n "$SERIAL_NUMBER" | base64 > "$SERIAL_FILE"
    chmod 644 "$SERIAL_FILE"
    set_immutable "$SERIAL_FILE"
    log "Saved base64 encoded serial to $SERIAL_FILE ..."

    echo -n "$PRODUCT_ID" > "$PRODUCT_FILE"
    chmod 644 "$PRODUCT_FILE"
    set_immutable "$PRODUCT_FILE"
    log "Saved product id to $PRODUCT_FILE ..."
fi

MACHINE_ID=$(echo -n "$SERIAL_NUMBER" | sha256sum | cut -c 1-32)
log "Generated machine-id: $MACHINE_ID ..."

if [ -n "$MACHINE_ID" ]; then
    if [ -s "/etc/machine-id" ]; then
        CURRENT_ID=$(cat /etc/machine-id)
        if [ "$CURRENT_ID" = "$MACHINE_ID" ]; then
            log "Machine ID already set correctly, no changes needed ..."
            cleanup 0
        fi
    fi

    echo "$MACHINE_ID" > /etc/machine-id
    chmod 444 /etc/machine-id
    log "Setting machine-id as immutable (requires chattr -i to modify in future) ..."
    set_immutable "/etc/machine-id"
    log "Written machine-id to /etc/machine-id ..."
    cleanup 0
else
    log "ERROR: Failed to generate valid machine-id ..."
    log "Will generate a random machine-id instead ..."
    systemd-machine-id-setup
    cleanup 1
fi