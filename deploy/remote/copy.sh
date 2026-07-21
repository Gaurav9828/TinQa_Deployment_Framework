#!/usr/bin/env bash

set -Eeuo pipefail

SSH_USER="${SSH_USER:-pi}"

copy_project() {

    local host="$1"
    local source="$2"

    rsync \
        -az \
        --delete \
        -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
        "${source}/" \
        "${SSH_USER}@${host}:/opt/tinqa"

}