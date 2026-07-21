#!/usr/bin/env bash

set -Eeuo pipefail

repair_network() {

    echo "Restarting NetworkManager..."

    sudo systemctl restart NetworkManager

    sleep 5

    ping -c2 8.8.8.8 || true

}

export -f repair_network