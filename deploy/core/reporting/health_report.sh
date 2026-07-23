#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# Health Report Engine
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################

HEALTH_REPORT=""

###############################################################################
# Report Location
###############################################################################

health_report_initialize() {

    if [[ "${DEPLOY_MODE:-PRODUCTION}" == "TEST" ]]
    then
        HEALTH_REPORT="${FAKE_PI_ROOT}/opt/tinqa/logs/health_report.txt"
    else
        HEALTH_REPORT="${PROJECT_ROOT}/logs/health_report.txt"
    fi

    mkdir -p "$(dirname "${HEALTH_REPORT}")"
}

###############################################################################
# Helpers
###############################################################################

report_line() {

    echo "$*" >> "${HEALTH_REPORT}"

}

report_separator() {

    printf '%0.s=' {1..72} >> "${HEALTH_REPORT}"
    echo >> "${HEALTH_REPORT}"

}

###############################################################################
# Header
###############################################################################

health_report_header() {

    report_separator

    report_line "TinQa Deployment Health Report"

    report_line "Generated : $(date)"

    report_separator

}

###############################################################################
# System Information
###############################################################################

health_report_system() {

    report_line ""
    report_line "SYSTEM INFORMATION"
    report_line ""

    report_line "Hostname : $(remote_exec hostname)"
    report_line "Kernel   : $(remote_exec uname -r)"
    report_line "CPU      : $(remote_exec uname -m)"
    report_line "Python   : $(remote_exec python3 --version)"
    report_line ""

}

###############################################################################
# Disk
###############################################################################

health_report_disk() {

    report_line "DISK"

    target_exec df -h / >> "${HEALTH_REPORT}"

    report_line ""

}

###############################################################################
# Memory
###############################################################################

health_report_memory() {

    report_line "MEMORY"

    target_exec free -m >> "${HEALTH_REPORT}"

    report_line ""

}

###############################################################################
# Bluetooth
###############################################################################

health_report_bluetooth() {

    report_line "BLUETOOTH"

    target_exec bluetoothctl list >> "${HEALTH_REPORT}" || true

    report_line ""

}

###############################################################################
# Services
###############################################################################

health_report_services() {

    report_line "SERVICES"

    for service in "${SYSTEMD_SERVICES[@]}"
    do

        printf "%-30s" "${service}" >> "${HEALTH_REPORT}"

        if remote_exec systemctl is-active "${service}" >/dev/null 2>&1
        then
            echo "RUNNING" >> "${HEALTH_REPORT}"
        else
            echo "STOPPED" >> "${HEALTH_REPORT}"
        fi

    done

    report_line ""

}

###############################################################################
# Deployment Plan
###############################################################################

health_report_actions() {

    report_line "EXECUTED MODULES"

    local action

    for action in "${ACTIONS[@]}"
    do
        report_line " - ${action}"
    done

    report_line ""

}

###############################################################################
# Reboot
###############################################################################

health_report_reboot() {

    report_line "REBOOT"

    if remote_exec test -f /var/run/reboot-required
    then
        report_line "Required : YES"
    else
        report_line "Required : NO"
    fi

    report_line ""

}

###############################################################################
# Deployment Health Summary
###############################################################################

health_report_summary() {

    report_line ""
    report_line "DEPLOYMENT HEALTH"
    report_line ""

    printf "%-35s : %s\n" "Project Structure"      "$(inspect_get project_structure_ok)"   >> "${HEALTH_REPORT}"
    printf "%-35s : %s\n" "Python Runtime"         "$(inspect_get python_runtime_ok)"      >> "${HEALTH_REPORT}"
    printf "%-35s : %s\n" "Virtual Environment"    "$(inspect_get venv_ok)"                >> "${HEALTH_REPORT}"
    printf "%-35s : %s\n" "Python Packages"        "$(inspect_get python_packages_ok)"     >> "${HEALTH_REPORT}"
    printf "%-35s : %s\n" "Dependencies"           "$(inspect_get dependency_health)"      >> "${HEALTH_REPORT}"
    printf "%-35s : %s\n" "Application Entry"      "$(inspect_get application_entry_ok)"   >> "${HEALTH_REPORT}"
    printf "%-35s : %s\n" "Application Import"     "$(inspect_get application_import_ok)"  >> "${HEALTH_REPORT}"
    printf "%-35s : %s\n" "Bluetooth"              "$(inspect_get bluetooth_ok)"           >> "${HEALTH_REPORT}"
    printf "%-35s : %s\n" "Systemd"                "$(inspect_get systemd_ok)"             >> "${HEALTH_REPORT}"
    printf "%-35s : %s\n" "Functional Tests"       "$(inspect_get functional_tests)"       >> "${HEALTH_REPORT}"

    report_line ""

}

###############################################################################
# Footer
###############################################################################

health_report_footer() {

    report_separator

    report_line "Deployment completed successfully."

    report_separator

}

###############################################################################
# Generate Report
###############################################################################

health_report_execute() {

    health_report_initialize

    health_report_header

    health_report_system

    health_report_disk

    health_report_memory

    health_report_bluetooth

    health_report_services

    health_report_actions

    health_report_summary

    health_report_reboot

    health_report_footer

    log_success "Health report generated."

    log_info "Report : ${HEALTH_REPORT}"

}

###############################################################################
# Export
###############################################################################

export -f health_report_execute