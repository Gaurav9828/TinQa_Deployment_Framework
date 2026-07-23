#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 04_cleanup.sh
# Version     : 1.0.0
#
# Description :
# Cleans previous deployment artifacts and prepares the system.
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

###############################################################################
# Stop Running Service
###############################################################################

stop_application_service() {

    log_info "Stopping application service..."

    if [[ -f "${SYSTEMD_SERVICE_FILE}" ]]
    then
        if systemctl is-active --quiet "${TINQA_SERVICE_NAME}"
        then
            systemctl stop "${TINQA_SERVICE_NAME}"

            log_success "Application service stopped."

        else

            log_info "Application service already stopped."

        fi
    else
        log_warning "Application service not installed."
    fi
}

###############################################################################
# Remove Temporary Files
###############################################################################

cleanup_temp_directory() {

    log_info "Cleaning temporary directory..."

    mkdir -p "${TEMP_DIRECTORY}"

    find "${TEMP_DIRECTORY}" \
        -mindepth 1 \
        -delete 2>/dev/null || true

    log_success "Temporary directory cleaned."
}

###############################################################################
# Remove Runtime Files
###############################################################################

cleanup_runtime_files() {

    log_info "Removing runtime files..."

    rm -f "${LOCK_FILE}" 2>/dev/null || true
    rm -f "${STATUS_FILE}" 2>/dev/null || true
    rm -f "${PID_FILE}" 2>/dev/null || true

    log_success "Runtime files removed."
}

###############################################################################
# Remove Previous Deployment
###############################################################################

cleanup_previous_deployment() {

    log_info "Removing previous deployment..."

    rm -rf "${PROJECT_ROOT}" 2>/dev/null || true

    mkdir -p "${PROJECT_ROOT}"

    log_success "Previous deployment removed."

}

###############################################################################
# Cleanup Old Logs
###############################################################################

cleanup_old_logs() {

    log_info "Cleaning previous deployment logs..."

    find "${LOG_DIRECTORY}" \
        -type f \
        -name "*.log" \
        -mtime +30 \
        -delete 2>/dev/null || true

    log_success "Old logs cleaned."

}

###############################################################################
# Create Required Directories
###############################################################################

create_required_directories() {

    log_info "Creating required directories..."

    local directory

    for directory in "${REQUIRED_DIRECTORIES[@]}"
    do
        mkdir -p "${directory}"
    done

    log_success "Required directories verified."
}

###############################################################################
# Validate Disk Space
###############################################################################

check_disk_space() {

    log_info "Checking available disk space..."

    local available_mb

    if [[ "${DEPLOY_MODE:-PRODUCTION}" == "TEST" ]]
    then

        available_mb=32768

    else

        if ! available_mb="$(df -Pm "${PROJECT_ROOT}" 2>/dev/null | awk 'NR==2 {print $4}')"
        then
            inspect_set disk_ok no

            log_error "Unable to determine available disk space."

            return 1
        fi

        if [[ -z "${available_mb}" ]]
        then
            inspect_set disk_ok no

            log_error "Disk space information unavailable."

            return 1
        fi

    fi

    if (( available_mb < 1024 ))
    then
        inspect_set disk_ok no

        log_error "Less than 1GB free disk space."

        return 1
    fi

    inspect_set disk_ok yes

    log_success "Disk space OK (${available_mb} MB available)."

}

###############################################################################
# Main
###############################################################################

run_04_cleanup() {

    section "Module 04 - Cleanup"

    stop_application_service
    cleanup_temp_directory
    cleanup_runtime_files
    cleanup_previous_deployment
    cleanup_old_logs
    create_required_directories
    check_disk_space

    log_success "Cleanup module completed."
}

###############################################################################
# Public API
###############################################################################

export -f run_04_cleanup