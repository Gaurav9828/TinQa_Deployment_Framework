#!/usr/bin/env bash

inspect_storage() {

    local free

    free=$(remote_exec "df --output=avail / | tail -1")

    inspect_set disk "${free}"
}

export -f inspect_storage