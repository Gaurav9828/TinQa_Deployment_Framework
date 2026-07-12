#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : service_logs.sh
# Version     : 1.0.0
#
# Description :
# Collects service logs for troubleshooting.
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
# Report File
###############################################################################

SERVICE_LOG_FILE="${DIAGNOSTIC_LOG_DIRECTORY}/service_logs.log"

###############################################################################
# Helper
###############################################################################

append() {

    echo "$1" >> "${SERVICE_LOG_FILE}"

}

###############################################################################
# Header
###############################################################################

service_logs_header() {

    mkdir -p "${DIAGNOSTIC_LOG_DIRECTORY}"

    : > "${SERVICE_LOG_FILE}"

    append "=============================================================="
    append "TinQa Deployment Framework"
    append "Service Diagnostic Report"
    append "Generated : $(date)"
    append "=============================================================="
    append ""

}

###############################################################################
# Systemd Status
###############################################################################

collect_service_status() {

    append "================ SERVICE STATUS ================"

    for service in "${SERVICES_TO_ENABLE[@]}"
    do

        append ""
        append "------------------------------------------------"
        append "Service : ${service}"
        append "------------------------------------------------"

        systemctl status "${service}" \
            --no-pager \
            >> "${SERVICE_LOG_FILE}" 2>&1 || true

    done

    append ""

}

###############################################################################
# Journal Logs
###############################################################################

collect_journal_logs() {

    append "================ JOURNAL LOGS ================"

    for service in "${SERVICES_TO_ENABLE[@]}"
    do

        append ""
        append "------------------------------------------------"
        append "Journal : ${service}"
        append "------------------------------------------------"

        journalctl \
            -u "${service}" \
            -n 200 \
            --no-pager \
            >> "${SERVICE_LOG_FILE}" 2>&1 || true

    done

    append ""

}

###############################################################################
# Kernel Errors
###############################################################################

collect_kernel_logs() {

    append "================ KERNEL ================"

    dmesg -T | tail -200 \
        >> "${SERVICE_LOG_FILE}" 2>&1 || true

    append ""

}

###############################################################################
# Deployment Logs
###############################################################################

collect_deployment_logs() {

    append "================ DEPLOYMENT LOGS ================"

    if [[ -d "${DEPLOYMENT_LOG_DIRECTORY}" ]]; then

        find "${DEPLOYMENT_LOG_DIRECTORY}" \
            -type f \
            -name "*.log" \
            -print | while read -r file
        do

            append ""
            append "------------------------------------------------"
            append "File : ${file}"
            append "------------------------------------------------"

            tail -100 "${file}" \
                >> "${SERVICE_LOG_FILE}" 2>&1 || true

        done

    else

        append "Deployment log directory not found."

    fi

    append ""

}

###############################################################################
# Python Logs
###############################################################################

collect_python_logs() {

    append "================ PYTHON ================"

    if [[ -d "${APPLICATION_LOG_DIRECTORY}" ]]; then

        find "${APPLICATION_LOG_DIRECTORY}" \
            -type f \
            -name "*.log" \
            -print | while read -r file
        do

            append ""
            append "------------------------------------------------"
            append "File : ${file}"
            append "------------------------------------------------"

            tail -100 "${file}" \
                >> "${SERVICE_LOG_FILE}" 2>&1 || true

        done

    else

        append "Application log directory not found."

    fi

    append ""

}

###############################################################################
# Bluetooth
###############################################################################

collect_bluetooth_logs() {

    append "================ BLUETOOTH ================"

    journalctl \
        -u "${BLUETOOTH_SERVICE_NAME}" \
        -n 200 \
        --no-pager \
        >> "${SERVICE_LOG_FILE}" 2>&1 || true

    append ""

}

###############################################################################
# NetworkManager
###############################################################################

collect_network_logs() {

    append "================ NETWORK MANAGER ================"

    journalctl \
        -u "${NETWORK_MANAGER_SERVICE_NAME}" \
        -n 200 \
        --no-pager \
        >> "${SERVICE_LOG_FILE}" 2>&1 || true

    append ""

}

###############################################################################
# Main
###############################################################################

collect_service_logs() {

    log_info "Collecting service logs..."

    service_logs_header

    collect_service_status

    collect_journal_logs

    collect_kernel_logs

    collect_deployment_logs

    collect_python_logs

    collect_bluetooth_logs

    collect_network_logs

    log_success "Service logs collected."

}

###############################################################################
# Public API
###############################################################################

export -f collect_service_logs