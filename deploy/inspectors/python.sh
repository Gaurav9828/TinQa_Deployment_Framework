#!/usr/bin/env bash

inspect_python() {

    if _exec python3 --version >/dev/null 2>&1
    then
        inspect_set python yes
    else
        inspect_set python no
    fi
}

export -f inspect_python