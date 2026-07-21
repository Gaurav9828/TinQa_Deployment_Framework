#!/usr/bin/env bash

set -Eeuo pipefail

repair_bluetooth() {

    echo "Restarting Bluetooth..."

    sudo systemctl restart bluetooth

    sleep 2

    bluetoothctl power on || true

    bluetoothctl discoverable on || true

    bluetoothctl pairable on || true

    echo "Bluetooth repaired."

}

export -f repair_bluetooth