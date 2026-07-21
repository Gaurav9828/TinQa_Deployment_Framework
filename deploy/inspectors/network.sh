#!/usr/bin/env bash

inspect_network() {

    if remote_exec systemctl is-active NetworkManager >/dev/null 2>&1
    then
        inspect_set network yes
    else
        inspect_set network no
    fi
}

export -f inspect_network