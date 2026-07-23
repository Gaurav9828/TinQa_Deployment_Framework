#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# Health Check Engine
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Execute Health Check
###############################################################################

health_check() {

    local target="$1"

    shift || true

    case "${target}" in

        python)
            health_python
            ;;

        bluetooth)
            health_bluetooth
            ;;

        network)
            health_network
            ;;

        packages)
            health_packages
            ;;

        disk)
            health_disk
            ;;

        systemd)
            health_systemd
            ;;

        permissions)
            health_permissions
            ;;

        service)
            health_service "$@"
            ;;

        *)
            log_error "Unknown health target: ${target}"
            return 1
            ;;

    esac

}

###############################################################################
# Python
###############################################################################

health_python() {

    remote_exec python3 --version >/dev/null

}

###############################################################################
# Bluetooth
###############################################################################

health_bluetooth() {

    remote_exec bluetoothctl list >/dev/null

}

###############################################################################
# Network
###############################################################################

health_network() {

    remote_exec ping -c1 8.8.8.8 >/dev/null

}

###############################################################################
# Package Manager
###############################################################################

health_packages() {

    remote_exec apt --version >/dev/null

}

###############################################################################
# Disk
###############################################################################

health_disk() {

    remote_exec df -h / >/dev/null

}

###############################################################################
# Systemd
###############################################################################

health_systemd() {

    remote_exec systemctl --version >/dev/null

}

###############################################################################
# Permissions
###############################################################################

health_permissions() {

    remote_exec test -w /opt

}

###############################################################################
# Generic Service
###############################################################################

health_service() {

    local service="$1"

    remote_exec systemctl is-active "${service}"

}

###############################################################################
# Public API
###############################################################################

export -f health_check
export -f health_python
export -f health_bluetooth
export -f health_network
export -f health_packages
export -f health_disk
export -f health_systemd
export -f health_permissions
export -f health_service