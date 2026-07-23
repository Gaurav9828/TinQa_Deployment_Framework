#!/usr/bin/env bash
###############################################################################
#
# Network Repair
#
###############################################################################

set -Eeuo pipefail

repair_network() {

    log_info "Verifying network connectivity..."

    if target_exec ping -c1 8.8.8.8 >/dev/null 2>&1
    then
        log_success "Internet available."
        return 0
    fi

    log_warning "Internet unavailable."

    log_info "Restarting ${NETWORK_MANAGER_SERVICE_NAME}..."

    target_exec sudo systemctl restart "${NETWORK_MANAGER_SERVICE_NAME}"

    sleep 5

    if target_exec ping -c1 8.8.8.8 >/dev/null 2>&1
    then
        log_success "Network restored."
        return 0
    fi

    log_error "Unable to restore network."

    return 1
}

export -f repair_network