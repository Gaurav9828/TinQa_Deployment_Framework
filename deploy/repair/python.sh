#!/usr/bin/env bash

set -Eeuo pipefail

repair_python() {

    if command -v python3 >/dev/null
    then
        return
    fi

    sudo apt update

    sudo apt install -y python3 python3-pip python3-venv

}

export -f repair_python