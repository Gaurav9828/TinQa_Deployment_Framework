#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : report.sh
# Version     : 1.0.0
#
# Description :
# Generates a complete diagnostic bundle for remote troubleshooting.
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

###############################################################################
# Files
###############################################################################

REPORT_DIRECTORY="${DIAGNOSTIC_LOG_DIRECTORY}/report"

REPORT_FILE="${REPORT_DIRECTORY}/diagnostic_report.txt"

ARCHIVE_NAME="TinQa_Diagnostics_$(date +%Y%m%d_%H%M%S).tar.gz"

ARCHIVE_FILE="${DIAGNOSTIC_LOG_DIRECTORY}/${ARCHIVE_NAME}"

REPORT_DIRECTORY="${DIAGNOSTIC_LOG_DIRECTORY}/report"
REPORT_FILE="${REPORT_DIRECTORY}/diagnostic_report.txt"

mkdir -p "${REPORT_DIRECTORY}"

echo "TinQa Diagnostic Report" > "${REPORT_FILE}"

###############################################################################
# Helper
###############################################################################

append() {

    echo "$1" >> "${REPORT_FILE}"

}

###############################################################################
# Header
###############################################################################

report_header() {

    mkdir -p "${REPORT_DIRECTORY}"

    : > "${REPORT_FILE}"

    append "=============================================================="

    append "TinQa Deployment Framework"

    append "Diagnostic Report"

    append "Generated : $(date)"

    append "Hostname  : $(hostname)"

    append "=============================================================="

    append ""

}

###############################################################################
# Deployment Summary
###############################################################################

deployment_summary() {

    append "================ Deployment Summary ================"

    append "Project Name      : ${PROJECT_NAME}"

    append "Project Root      : ${PROJECT_ROOT}"

    append "Project User      : ${PROJECT_USER}"

    append "Deployment Logs   : ${DEPLOYMENT_LOG_DIRECTORY}"

    append "Application Logs  : ${APPLICATION_LOG_DIRECTORY}"

    append ""

}

###############################################################################
# Include File
###############################################################################

include_file() {

    local file="$1"

    [[ -f "${file}" ]] || return 0

    append "=============================================================="

    append "FILE : $(basename "${file}")"

    append "=============================================================="

    cat "${file}" >> "${REPORT_FILE}"

    append ""

}

###############################################################################
# Collect Reports
###############################################################################

collect_reports() {

    include_file "${DIAGNOSTIC_LOG_DIRECTORY}/system_information.log"

    include_file "${DIAGNOSTIC_LOG_DIRECTORY}/service_logs.log"

}

###############################################################################
# Compress Report
###############################################################################

compress_report() {

    tar -czf "${ARCHIVE_FILE}" \
        -C "${DIAGNOSTIC_LOG_DIRECTORY}" .

}

###############################################################################
# Report Size
###############################################################################

report_size() {

    du -sh "${ARCHIVE_FILE}" 2>/dev/null | cut -f1

}

###############################################################################
# Generate Report
###############################################################################

generate_report() {

    log_info "Generating diagnostic report..."

    report_header

    deployment_summary

    collect_reports

    compress_report

    log_success "Diagnostic bundle created."

    log_info "Archive : ${ARCHIVE_FILE}"

    log_info "Size    : $(report_size)"

}

###############################################################################
# Cleanup
###############################################################################

cleanup_report() {

    rm -rf "${REPORT_DIRECTORY}"

}

###############################################################################
# Public API
###############################################################################

export -f \
    generate_report \
    cleanup_report