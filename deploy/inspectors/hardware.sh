#!/usr/bin/env bash

set -Eeuo pipefail

inspect_hardware() {

    echo "Hardware"

    if command -v vcgencmd >/dev/null
    then
        vcgencmd measure_temp
    else
        echo "Temperature : Unsupported"
    fi

}

export -f inspect_hardware