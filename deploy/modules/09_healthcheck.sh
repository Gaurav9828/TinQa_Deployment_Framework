#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 09_healthcheck.sh
# Version     : 1.0.0
#
# Description :
# Performs complete post-deployment health checks.
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

source "${DEPLOY_ROOT}/config/files.conf"
source "${DEPLOY_ROOT}/config/services.conf"

source "${DEPLOY_ROOT}/validators/bluetooth.sh"

###############################################################################
# Service Health
###############################################################################

check_service_health() {

    log_info "Checking TinQa service..."

    if systemctl is-active --quiet "${TINQA_SERVICE_NAME}"
    then
        log_success "TinQa service is running."
        return 0
    fi

    log_error "TinQa service is not running."

    return 1

}

###############################################################################
# Service Boot Status
###############################################################################

check_service_enabled() {

    log_info "Checking boot configuration..."

    if systemctl is-enabled --quiet "${TINQA_SERVICE_NAME}"
    then
        log_success "Service is enabled at boot."
        return 0
    fi

    log_error "Service is not enabled."

    return 1

}

###############################################################################
# Python Runtime
###############################################################################

check_python_runtime() {

    log_info "Checking Python process..."

    if pgrep -f "app.main" >/dev/null
    then
        log_success "Python application is running."
        return 0
    fi

    log_warning "Python process not detected."

    return 1

}

###############################################################################
# Bluetooth
###############################################################################

check_bluetooth_health() {

    log_info "Checking Bluetooth..."

    validate_bluetooth

}

###############################################################################
# Journal Errors
###############################################################################

check_recent_errors() {

    if [[ "${DEPLOY_MODE}" == "TEST" ]]
    then
        log_info "Checking recent journal errors..."
        log_success "Journal validation skipped (TEST MODE)."
        return 0
    fi

    log_info "Checking recent journal errors..."

    local errors

    errors=$(
        journalctl \
            -u "${TINQA_SERVICE_NAME}" \
            --since "5 minutes ago" \
            -p err \
            --no-pager \
            | wc -l
    )

    if [[ "${errors}" -eq 0 ]]
    then
        log_success "No recent errors found."
    else
        log_warning "${errors} recent errors detected."
    fi
}

###############################################################################
# Resource Usage
###############################################################################

check_resource_usage() {

    log_info "Collecting resource usage..."

    echo

    free -h

    echo

    df -h

    echo

    log_success "Resource usage collected."

}

###############################################################################
# Overall Health
###############################################################################

health_summary() {

    echo

    ui_line

    ui_center "DEPLOYMENT HEALTH STATUS"

    ui_line

    echo

    systemctl status \
        "${TINQA_SERVICE_NAME}" \
        --no-pager \
        || true

    echo

}

###############################################################################
# Main
###############################################################################

run_healthcheck() {

    section "Module 09 - Health Check"

    check_service_health

    check_service_enabled

    check_python_runtime

    check_bluetooth_health

    check_recent_errors

    check_resource_usage

    health_summary

    log_success "Health check completed."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_healthcheck