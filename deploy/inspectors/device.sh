#!/usr/bin/env bash

set -Eeuo pipefail

inspect_device() {

    echo "Device"

    echo "Hostname    : $(hostname)"
    echo "Kernel      : $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "User        : $(whoami)"

}

export -f inspect_device