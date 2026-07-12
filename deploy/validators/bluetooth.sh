#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : bluetooth.sh
# Version     : 1.0.0
#
# Description :
# Bluetooth validation helper functions.
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

###############################################################################
# Service Validation
###############################################################################

validate_bluetooth_service() {

    log_info "Checking Bluetooth service..."

    if systemctl is-active --quiet "${BLUETOOTH_SERVICE_NAME}"
    then

        log_success "Bluetooth service is running."

        return 0

    fi

    log_error "Bluetooth service is not running."

    return 1

}

###############################################################################
# Adapter Validation
###############################################################################

validate_bluetooth_adapter() {

    log_info "Checking Bluetooth adapter..."

    if bluetoothctl list | grep -q "^Controller"
    then
        log_success "Bluetooth adapter detected."
        return 0
    fi

    log_error "Bluetooth adapter not detected."
    return 1
}

###############################################################################
# Adapter Power
###############################################################################

validate_adapter_power() {

    log_info "Checking adapter power..."

    if bluetoothctl show | grep -q "Powered: yes"
    then

        log_success "Bluetooth adapter is powered."

        return 0

    fi

    log_error "Bluetooth adapter is powered off."

    return 1

}

###############################################################################
# Adapter Discoverable
###############################################################################

validate_discoverable() {

    log_info "Checking discoverable mode..."

    if bluetoothctl show | grep -q "Discoverable: yes"
    then

        log_success "Adapter is discoverable."

        return 0

    fi

    log_warning "Adapter is not discoverable."

    return 1

}

###############################################################################
# Adapter Pairable
###############################################################################

validate_pairable() {

    log_info "Checking pairable mode..."

    if bluetoothctl show | grep -q "Pairable: yes"
    then

        log_success "Adapter is pairable."

        return 0

    fi

    log_warning "Adapter is not pairable."

    return 1

}

###############################################################################
# Overall Validation
###############################################################################

validate_bluetooth() {

    local result=0

    validate_bluetooth_service || result=1

    validate_bluetooth_adapter || result=1

    validate_adapter_power || result=1

    validate_discoverable || true

    validate_pairable || true

    return "${result}"

}

###############################################################################
# Public API
###############################################################################

export -f \
    validate_bluetooth \
    validate_bluetooth_service \
    validate_bluetooth_adapter \
    validate_adapter_power \
    validate_discoverable \
    validate_pairable