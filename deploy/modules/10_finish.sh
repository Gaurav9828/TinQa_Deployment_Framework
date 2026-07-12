#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 10_finish.sh
# Version     : 1.0.0
#
# Description :
# Final deployment tasks, diagnostics, cleanup and summary.
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

source "${DEPLOY_ROOT}/diagnostics/system_info.sh"
source "${DEPLOY_ROOT}/diagnostics/service_logs.sh"
source "${DEPLOY_ROOT}/diagnostics/report.sh"

###############################################################################
# Generate Diagnostics
###############################################################################

generate_diagnostics() {

    log_info "Generating diagnostics..."

    collect_system_information

    collect_service_logs

    generate_report

    log_success "Diagnostics generated."

}

###############################################################################
# Cleanup Temporary Files
###############################################################################

cleanup_temporary_files() {

    log_info "Cleaning temporary files..."

    rm -rf "${TEMP_DIRECTORY}"/* 2>/dev/null || true

    log_success "Temporary files removed."

}

###############################################################################
# Display Deployment Summary
###############################################################################

display_summary() {

    deployment_finished

}

###############################################################################
# Session Statistics
###############################################################################

display_statistics() {

    echo

    ui_line

    ui_center "DEPLOYMENT STATISTICS"

    ui_line

    echo

    printf "Started  : %s\n" "${DEPLOYMENT_START_TIME:-Unknown}"

    printf "Finished : %s\n" "$(date)"

    printf "Duration : %s seconds\n" "${SECONDS}"

    printf "Errors   : %s\n" "${ERROR_COUNT}"

    printf "Warnings : %s\n" "${WARNING_COUNT}"

    printf "Logs     : %s\n" "${DEPLOYMENT_LOG_DIRECTORY}"

    echo

}

###############################################################################
# Goodbye
###############################################################################

finish_message() {

    goodbye

}

###############################################################################
# Main
###############################################################################

run_finish() {

    section "Module 10 - Finish"

    generate_diagnostics

    cleanup_temporary_files

    display_summary

    display_statistics

    finish_message

    log_success "Deployment completed successfully."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_finish