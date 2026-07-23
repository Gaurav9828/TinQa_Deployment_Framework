#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 14_finish.sh
# Version     : 1.0.0
#
# Description :
# Final deployment summary and completion module.
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
# Deployment Duration
###############################################################################

show_deployment_duration() {

    log_info "Deployment Summary"

    local end_time
    local duration

    end_time="$(date +%s)"
    duration=$(( end_time - DEPLOYMENT_START_EPOCH ))

    printf "\n"
    printf "Deployment Time : %02d:%02d\n" \
        $((duration / 60)) \
        $((duration % 60))
    printf "\n"

}

###############################################################################
# Reports
###############################################################################

show_report_locations() {

    log_info "Generated Reports"

    printf "Health Report      : %s\n" "${HEALTH_REPORT:-Not Generated}"
    printf "Deployment Report  : %s\n" "${DEPLOYMENT_REPORT:-Not Generated}"
    printf "Installed Packages : %s\n" \
        "${APPLICATION_LOG_DIRECTORY:-/tmp}/installed_packages.txt"

    printf "\n"

}

###############################################################################
# Reboot Status
###############################################################################

show_reboot_status() {

    log_info "Reboot Status"

    if remote_exec test -f /var/run/reboot-required
    then
        log_warning "System reboot is recommended."
    else
        log_success "No reboot required."
    fi

    printf "\n"

}

###############################################################################
# Deployment Result
###############################################################################

show_deployment_result() {

    log_info "Deployment Result"

    if inspect_yes functional_tests &&
       inspect_yes systemd_ok &&
       inspect_yes bluetooth_ok
    then

        log_success "TinQa is READY for production deployment."

    else

        log_warning "Deployment completed with warnings."

    fi

    printf "\n"

}

###############################################################################
# Finish Banner
###############################################################################

show_finish_banner() {

    echo
    echo "=============================================================="
    echo "           TinQa Deployment Completed Successfully"
    echo "=============================================================="
    echo

}

###############################################################################
# Main
###############################################################################


run_14_finish() {

    section "Module 14 - Finish"

    show_deployment_duration

    show_report_locations

    show_reboot_status

    show_deployment_result

    show_finish_banner

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_14_finish