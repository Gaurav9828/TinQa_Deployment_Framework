#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : bluetooth.sh
# Version     : 1.0.0
#
# Description :
# Creates a fake Bluetooth environment inside the sandbox.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Directories
###############################################################################

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SANDBOX_DIR="${TEST_DIR}/sandbox"

BLUETOOTH_DIR="${SANDBOX_DIR}/etc/bluetooth"

###############################################################################
# Fake Bluetooth Configuration
###############################################################################

create_bluetooth_config() {

    mkdir -p "${BLUETOOTH_DIR}"

cat > "${BLUETOOTH_DIR}/main.conf" <<EOF
[General]
Name=TinQa Test Adapter
Class=0x000100
DiscoverableTimeout=0
PairableTimeout=0
EOF

}

###############################################################################
# Fake Bluetooth Adapter
###############################################################################

create_bluetooth_adapter() {

    mkdir -p \
        "${SANDBOX_DIR}/sys/class/bluetooth/hci0"

    touch \
        "${SANDBOX_DIR}/sys/class/bluetooth/hci0/address"

    echo "00:11:22:33:44:55" \
        > "${SANDBOX_DIR}/sys/class/bluetooth/hci0/address"

}

###############################################################################
# Fake Paired Devices
###############################################################################

create_paired_devices() {

    mkdir -p \
        "${BLUETOOTH_DIR}/devices"

cat > "${BLUETOOTH_DIR}/devices/paired_devices" <<EOF
AA:BB:CC:DD:EE:01
AA:BB:CC:DD:EE:02
EOF

}

###############################################################################
# Fake Bluetooth Service
###############################################################################

create_bluetooth_service() {

    mkdir -p \
        "${SANDBOX_DIR}/etc/systemd/system"

cat > "${SANDBOX_DIR}/etc/systemd/system/bluetooth.service" <<EOF
[Unit]
Description=Bluetooth Service

[Service]
ExecStart=/usr/lib/bluetooth/bluetoothd

[Install]
WantedBy=multi-user.target
EOF

}

###############################################################################
# Fake bluetoothctl Output
###############################################################################

create_bluetoothctl_output() {

cat > "${SANDBOX_DIR}/bluetoothctl.out" <<EOF
Controller 00:11:22:33:44:55 TinQa Bluetooth [default]
Powered: yes
Discoverable: yes
Pairable: yes
EOF

}

###############################################################################
# Initialize Bluetooth
###############################################################################

initialize_bluetooth() {

    create_bluetooth_config

    create_bluetooth_adapter

    create_paired_devices

    create_bluetooth_service

    create_bluetoothctl_output

}

###############################################################################
# Public API
###############################################################################

export -f \
    create_bluetooth_config \
    create_bluetooth_adapter \
    create_paired_devices \
    create_bluetooth_service \
    create_bluetoothctl_output \
    initialize_bluetooth