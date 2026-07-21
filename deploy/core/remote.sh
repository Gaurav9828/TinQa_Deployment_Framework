#!/usr/bin/env bash
###############################################################################
#
# TinQa Remote Execution Engine
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################

: "${REMOTE_HOST:=}"
: "${SSH_USER:=pi}"

SSH_OPTIONS=(
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -o ConnectTimeout=10
)

###############################################################################
# Host
###############################################################################

remote_set_host() {

    REMOTE_HOST="$1"

}

###############################################################################
# Execute
###############################################################################

remote_exec() {

    [[ -n "${REMOTE_HOST}" ]] || {
        echo "REMOTE_HOST not configured."
        return 1
    }

    ssh \
        "${SSH_OPTIONS[@]}" \
        "${SSH_USER}@${REMOTE_HOST}" \
        "$@"

}

###############################################################################
# Copy To Pi
###############################################################################

remote_copy() {

    local source="$1"
    local destination="$2"

    rsync \
        -az \
        --delete \
        -e "ssh ${SSH_OPTIONS[*]}" \
        "${source}" \
        "${SSH_USER}@${REMOTE_HOST}:${destination}"

}

###############################################################################
# Copy From Pi
###############################################################################

remote_fetch() {

    local source="$1"
    local destination="$2"

    rsync \
        -az \
        -e "ssh ${SSH_OPTIONS[*]}" \
        "${SSH_USER}@${REMOTE_HOST}:${source}" \
        "${destination}"

}

###############################################################################
# Directory
###############################################################################

remote_mkdir() {

    remote_exec mkdir -p "$1"

}

###############################################################################
# Exists
###############################################################################

remote_exists() {

    remote_exec test -e "$1"

}

###############################################################################
# Service
###############################################################################

remote_service_restart() {

    remote_exec sudo systemctl restart "$1"

}

remote_service_enable() {

    remote_exec sudo systemctl enable "$1"

}

remote_service_status() {

    remote_exec systemctl status "$1" --no-pager

}

###############################################################################
# Packages
###############################################################################

remote_install_packages() {

    remote_exec sudo apt install -y "$@"

}

###############################################################################
# Update
###############################################################################

remote_update() {

    remote_exec sudo apt update

}

###############################################################################
# Upgrade
###############################################################################

remote_upgrade() {

    remote_exec sudo apt full-upgrade -y

}

###############################################################################
# Reboot
###############################################################################

remote_reboot() {

    remote_exec sudo reboot

}

###############################################################################
# Python
###############################################################################

remote_create_venv() {

    remote_exec python3 -m venv "$1"

}

###############################################################################
# Export
###############################################################################

export -f remote_set_host
export -f remote_exec
export -f remote_copy
export -f remote_fetch
export -f remote_exists
export -f remote_mkdir
export -f remote_update
export -f remote_upgrade
export -f remote_install_packages
export -f remote_create_venv
export -f remote_service_restart
export -f remote_service_enable
export -f remote_service_status
export -f remote_reboot