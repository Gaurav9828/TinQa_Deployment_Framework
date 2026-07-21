#!/usr/bin/env bash
###############################################################################
#
# Module 00 - Preflight
#
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${DEPLOY_ROOT}/core/remote.sh"

###############################################################################
# Helpers
###############################################################################

check_remote_command() {

    local description="$1"
    shift

    printf "%-40s" "${description}"

    ###########################################################################
    # TEST MODE
    ###########################################################################

    if [[ "${DEPLOY_MODE:-PRODUCTION}" == "TEST" ]]
    then
        echo "[ OK ]"
        return 0
    fi

    ###########################################################################
    # PRODUCTION
    ###########################################################################

    if remote_exec "$@" >/dev/null 2>&1
    then
        echo "[ OK ]"
    else
        echo "[FAIL]"
        return 1
    fi
}

###############################################################################
# Module
###############################################################################

run_00_preflight() {

    echo
    echo "=============================================================="
    echo "              Module 00 - Remote Preflight"
    echo "=============================================================="
    echo

    check_remote_command "SSH Connection" hostname
    check_remote_command "Internet Connectivity" ping -c1 8.8.8.8
    check_remote_command "Python Installed" python3 --version
    check_remote_command "APT Available" apt --version
    check_remote_command "Bluetooth Service" systemctl is-active bluetooth
    check_remote_command "NetworkManager Service" systemctl is-active NetworkManager
    check_remote_command "Bluetooth Adapter" bluetoothctl list
    check_remote_command "Disk Accessible" df -h /
    check_remote_command "Memory Accessible" free -m
    check_remote_command "/opt Exists" test -d /opt

    echo
    echo "Remote machine passed basic validation."
    echo
}

export -f run_00_preflight