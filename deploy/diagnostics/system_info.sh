#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : system_info.sh
# Version     : 1.0.0
#
# Description :
# Collects complete system information for diagnostics.
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
# Report File
###############################################################################

SYSTEM_INFO_FILE="${DIAGNOSTIC_LOG_DIRECTORY}/system_information.log"

###############################################################################
# Helper
###############################################################################

append() {

    echo "$1" >> "${SYSTEM_INFO_FILE}"

}

###############################################################################
# Header
###############################################################################

system_info_header() {

    mkdir -p "${DIAGNOSTIC_LOG_DIRECTORY}"

    : > "${SYSTEM_INFO_FILE}"

    append "=============================================================="
    append "TinQa Deployment Framework"
    append "System Information Report"
    append "Generated : $(date)"
    append "=============================================================="
    append ""

}

###############################################################################
# Host Information
###############################################################################

collect_host_information() {

    append "---------------- Host ----------------"

    append "Hostname      : $(hostname)"

    append "User          : $(whoami)"

    append "Kernel        : $(uname -r)"

    append "Architecture  : $(uname -m)"

    append "OS            : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"

    append ""

}

###############################################################################
# CPU
###############################################################################

collect_cpu_information() {

    append "---------------- CPU ----------------"

    lscpu >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

}

###############################################################################
# Memory
###############################################################################

collect_memory_information() {

    append "---------------- Memory ----------------"

    free -h >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

}

###############################################################################
# Storage
###############################################################################

collect_storage_information() {

    append "---------------- Storage ----------------"

    df -h >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

}

###############################################################################
# Network
###############################################################################

collect_network_information() {

    append "---------------- Network ----------------"

    ip address >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

    ip route >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

}

###############################################################################
# Bluetooth
###############################################################################

collect_bluetooth_information() {

    append "---------------- Bluetooth ----------------"

    bluetoothctl show >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

    hciconfig >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

}

###############################################################################
# Python
###############################################################################

collect_python_information() {

    append "---------------- Python ----------------"

    python3 --version >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    pip3 --version >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

}

###############################################################################
# Installed Packages
###############################################################################

collect_package_information() {

    append "---------------- Packages ----------------"

    dpkg -l >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

}

###############################################################################
# Services
###############################################################################

collect_service_information() {

    append "---------------- Services ----------------"

    systemctl status bluetooth --no-pager >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

    systemctl status NetworkManager --no-pager >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

    systemctl status tinqa --no-pager >> "${SYSTEM_INFO_FILE}" 2>/dev/null || true

    append ""

}

###############################################################################
# Environment
###############################################################################

collect_environment_information() {

    append "---------------- Environment ----------------"

    env | sort >> "${SYSTEM_INFO_FILE}"

    append ""

}

###############################################################################
# Main
###############################################################################

collect_system_information() {

    log_info "Collecting system information..."

    system_info_header

    collect_host_information

    collect_cpu_information

    collect_memory_information

    collect_storage_information

    collect_network_information

    collect_bluetooth_information

    collect_python_information

    collect_package_information

    collect_service_information

    collect_environment_information

    log_success "System information saved."

}

###############################################################################
# Public API
###############################################################################

export -f collect_system_information