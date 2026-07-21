#!/usr/bin/env bash

set -Eeuo pipefail

repair_packages() {

    sudo apt update

    sudo apt --fix-broken install -y

    sudo dpkg --configure -a

}

export -f repair_packages