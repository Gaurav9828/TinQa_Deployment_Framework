#!/usr/bin/env bash

inspect_updates() {

    local count

    count=$(remote_exec "apt list --upgradable 2>/dev/null | tail -n +2 | wc -l")

    inspect_set updates "${count}"
}

export -f inspect_updates