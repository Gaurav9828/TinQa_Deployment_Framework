#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 10 - Finish
###############################################################################

set -Eeuo pipefail

finish_deployment() {

    module_begin "Deployment Summary"

###############################################################################
# Calculate Duration
###############################################################################

    DEPLOYMENT_END_TIME=$(date +%s)
    TOTAL_TIME=$((DEPLOYMENT_END_TIME-DEPLOYMENT_START_TIME))

###############################################################################
# Raspberry Pi Information
###############################################################################

    PI_HOSTNAME=$(remote_hostname)
    PI_OS=$(remote_os)
    PI_IP=$(remote_ip)
    PI_UPTIME=$(remote_uptime)
    PYTHON_VERSION=$(remote_python_version)

###############################################################################
# Service Information
###############################################################################

    SERVICE_STATUS=$(service_status "${SERVICE_NAME}")

    SERVICE_PID=$(remote_exec \
        "systemctl show ${SERVICE_NAME} --property MainPID --value")

###############################################################################
# Dashboard
###############################################################################

    log_line
    log_section "DEPLOYMENT DASHBOARD"

    printf "\n"

    printf "%-35s %s\n" "Project"                 "${PROJECT_NAME}"
    printf "%-35s %s\n" "Framework Version"       "${FRAMEWORK_VERSION}"

    printf "\n"

    printf "%-35s %s\n" "Hostname"                "${PI_HOSTNAME}"
    printf "%-35s %s\n" "IP Address"              "${PI_IP}"
    printf "%-35s %s\n" "Operating System"        "${PI_OS}"
    printf "%-35s %s\n" "Python"                  "${PYTHON_VERSION}"

    printf "\n"

    printf "%-35s %s\n" "Service"                 "${SERVICE_NAME}"
    printf "%-35s %s\n" "Status"                  "${SERVICE_STATUS}"
    printf "%-35s %s\n" "PID"                     "${SERVICE_PID}"

    printf "\n"

    printf "%-35s %s\n" "Deployment Time"         "$(human_time "$TOTAL_TIME")"

    printf "%-35s %s\n" "Successful Steps"        "${SUCCESS_COUNT}"
    printf "%-35s %s\n" "Warnings"                "${WARNING_COUNT}"
    printf "%-35s %s\n" "Errors"                  "${ERROR_COUNT}"

###############################################################################
# Installed Package Versions
###############################################################################

    printf "\n"

    log_section "INSTALLED PYTHON PACKAGES"

    remote_exec \
        "
        source ${REMOTE_VENV}/bin/activate &&
        pip list
        "

###############################################################################
# Disk Usage
###############################################################################

    printf "\n"

    log_section "SYSTEM RESOURCES"

    remote_exec \
        "
        echo
        echo 'Disk'
        df -h /

        echo

        echo 'Memory'
        free -h

        echo

        echo 'CPU'
        uptime
        "

###############################################################################
# Save Report
###############################################################################

    REPORT_FILE="${LOG_DIRECTORY}/deployment_report_$(date +%Y%m%d_%H%M%S).txt"

    {

        echo "TinQa Deployment Report"

        echo

        echo "Project : ${PROJECT_NAME}"

        echo "Version : ${FRAMEWORK_VERSION}"

        echo

        echo "Host : ${PI_HOSTNAME}"

        echo "IP : ${PI_IP}"

        echo

        echo "Deployment Time : $(human_time "$TOTAL_TIME")"

        echo

        echo "Success : ${SUCCESS_COUNT}"

        echo "Warnings : ${WARNING_COUNT}"

        echo "Errors : ${ERROR_COUNT}"

    } > "${REPORT_FILE}"

###############################################################################
# Final Status
###############################################################################

    if (( ERROR_COUNT == 0 )); then

        success_banner

        log_success "Deployment completed successfully."

    else

        failure_banner

        log_error "Deployment completed with errors."

    fi

    printf "\n"

    log_info "Deployment Log"

    printf "   %s\n" "${LOG_FILE}"

    printf "\n"

    log_info "Deployment Report"

    printf "   %s\n" "${REPORT_FILE}"

    printf "\n"

    finish_logger

}