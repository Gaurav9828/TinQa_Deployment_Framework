#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 06_bluetooth.sh
# Version     : 1.0.0
#
# Description :
# Configures and prepares Bluetooth services.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Directories
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

###############################################################################
# Dependencies
###############################################################################

source "${DEPLOY_ROOT}/core/logger.sh"

source "${DEPLOY_ROOT}/config/services.conf"

source "${DEPLOY_ROOT}/validators/bluetooth.sh"

###############################################################################
# Enable Bluetooth Service
###############################################################################

enable_bluetooth_service() {

    log_info "Enabling Bluetooth service..."

    if ! sudo systemctl enable "${BLUETOOTH_SERVICE_NAME}"
    then

        repair_execute \
            "Bluetooth" \
            repair_bluetooth

        sudo systemctl enable "${BLUETOOTH_SERVICE_NAME}"

    fi

    log_success "Bluetooth service enabled."

}

###############################################################################
# Start Bluetooth Service
###############################################################################

start_bluetooth_service() {

    log_info "Starting Bluetooth service..."

    if ! sudo systemctl restart "${BLUETOOTH_SERVICE_NAME}"
    then

        repair_execute \
            "Bluetooth" \
            repair_bluetooth

        sudo systemctl restart "${BLUETOOTH_SERVICE_NAME}"

    fi

    log_success "Bluetooth service started."

}

###############################################################################
# Wait For Adapter
###############################################################################

wait_for_adapter() {
    if [[ "${DEPLOY_MODE:-PRODUCTION}" == "TEST" ]]; then
        inspect_set bluetooth_adapter yes
        log_success "Bluetooth adapter detected (TEST MODE)."
        return 0
    fi
    log_info "Waiting for Bluetooth adapter..."

    local retries=10

    while (( retries > 0 ))
    do

        if bluetoothctl list | grep -q "${BLUETOOTH_ADAPTER}"
        then
            inspect_set bluetooth_adapter yes
            log_success "Bluetooth adapter detected."

            return 0

        fi

        sleep 2

        ((retries--))

    done

    inspect_set bluetooth_adapter no

    log_error "Bluetooth adapter not detected."

    return 1

}

###############################################################################
# Power Adapter
###############################################################################

power_adapter() {

    log_info "Powering Bluetooth adapter..."

    bluetoothctl <<EOF >/dev/null
power on
quit
EOF

    log_success "Bluetooth adapter powered."

}

###############################################################################
# Enable Pairable
###############################################################################

enable_pairable() {

    log_info "Enabling pairable mode..."

    bluetoothctl <<EOF >/dev/null
pairable on
quit
EOF

    log_success "Pairable mode enabled."

}

###############################################################################
# Enable Discoverable
###############################################################################

enable_discoverable() {

    log_info "Enabling discoverable mode..."

    bluetoothctl <<EOF >/dev/null
discoverable on
quit
EOF

    log_success "Discoverable mode enabled."

}

###############################################################################
# Validate Configuration
###############################################################################

validate_configuration() {

    log_info "Running Bluetooth validation..."

    if validate_bluetooth
    then

        inspect_set bluetooth_ok yes

        log_success "Bluetooth validation completed."

    else

        inspect_set bluetooth_ok no

        return 1

    fi

}

###############################################################################
# Main
###############################################################################

run_09_bluetooth() {

    section "Module 09 - Bluetooth"

    enable_bluetooth_service

    start_bluetooth_service

    if ! systemctl is-active --quiet "${BLUETOOTH_SERVICE_NAME}"
    then
        log_error "Bluetooth service failed to start."

        return 1
    fi

    wait_for_adapter

    power_adapter

    enable_pairable

    enable_discoverable

    validate_configuration

    log_success "Bluetooth configuration completed."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_09_bluetooth