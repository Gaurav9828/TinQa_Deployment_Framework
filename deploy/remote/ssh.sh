#!/usr/bin/env bash

set -Eeuo pipefail

###############################################################################
# SSH
###############################################################################

SSH_USER="${SSH_USER:-pi}"

ssh_exec() {

    local host="$1"
    shift

    ssh \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "${SSH_USER}@${host}" \
        "$@"

}

ssh_test() {

    local host="$1"

    ssh_exec "$host" "echo OK" >/dev/null

}