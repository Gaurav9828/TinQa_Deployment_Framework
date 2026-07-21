#!/usr/bin/env bash

inspect_bluetooth() {

    if remote_exec bluetoothctl show >/dev/null 2>&1
    then
        inspect_set bluetooth yes
    else
        inspect_set bluetooth no
    fi
}

export -f inspect_bluetooth