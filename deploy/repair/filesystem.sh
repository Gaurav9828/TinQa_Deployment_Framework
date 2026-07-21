#!/usr/bin/env bash

set -Eeuo pipefail

repair_filesystem() {

    sudo apt autoremove -y

    sudo apt clean

    sudo journalctl --vacuum-time=3d

}

export -f repair_filesystem