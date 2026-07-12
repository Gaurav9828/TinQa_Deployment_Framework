#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File : errors.sh
#
# Version : 1.0.0
#
# Centralized Error Registry
#
###############################################################################

set -Eeuo pipefail

readonly ERRORS_VERSION="1.0.0"

###############################################################################
# Error Categories
###############################################################################

readonly CATEGORY_SYSTEM="SYSTEM"
readonly CATEGORY_NETWORK="NETWORK"
readonly CATEGORY_DEPLOYMENT="DEPLOYMENT"
readonly CATEGORY_PACKAGE="PACKAGE"
readonly CATEGORY_SERVICE="SERVICE"
readonly CATEGORY_PYTHON="PYTHON"
readonly CATEGORY_BLUETOOTH="BLUETOOTH"
readonly CATEGORY_CONFIGURATION="CONFIGURATION"
readonly CATEGORY_VALIDATION="VALIDATION"
readonly CATEGORY_UNKNOWN="UNKNOWN"

###############################################################################
# Error Severity
###############################################################################

readonly SEVERITY_INFO="INFO"
readonly SEVERITY_WARNING="WARNING"
readonly SEVERITY_ERROR="ERROR"
readonly SEVERITY_FATAL="FATAL"

###############################################################################
# Registry
###############################################################################

declare -Ag ERROR_CATEGORY
declare -Ag ERROR_SEVERITY
declare -Ag ERROR_MESSAGE
declare -Ag ERROR_HINT

###############################################################################
# Registration Helper
###############################################################################

register_error() {

    local code="$1"
    local category="$2"
    local severity="$3"
    local message="$4"
    local hint="$5"

    ERROR_CATEGORY["${code}"]="${category}"
    ERROR_SEVERITY["${code}"]="${severity}"
    ERROR_MESSAGE["${code}"]="${message}"
    ERROR_HINT["${code}"]="${hint}"

}

###############################################################################
# Framework
###############################################################################

register_error \
"ERR-0001" \
"${CATEGORY_SYSTEM}" \
"${SEVERITY_FATAL}" \
"Framework initialization failed." \
"Verify logger.sh and config.sh."

register_error \
"ERR-0002" \
"${CATEGORY_CONFIGURATION}" \
"${SEVERITY_FATAL}" \
"Configuration validation failed." \
"Check config.sh."

register_error \
"ERR-0003" \
"${CATEGORY_SYSTEM}" \
"${SEVERITY_FATAL}" \
"Unsupported operating system." \
"Use a supported Linux distribution."

register_error \
"ERR-0004" \
"${CATEGORY_SYSTEM}" \
"${SEVERITY_FATAL}" \
"Unsupported CPU architecture." \
"Deploy on armv7l or aarch64."

register_error \
"ERR-0005" \
"${CATEGORY_VALIDATION}" \
"${SEVERITY_FATAL}" \
"Required command not found." \
"Install missing dependency."

register_error \
"ERR-0006" \
"${CATEGORY_NETWORK}" \
"${SEVERITY_FATAL}" \
"No network connectivity." \
"Verify internet connection."

register_error \
"ERR-0007" \
"${CATEGORY_SYSTEM}" \
"${SEVERITY_FATAL}" \
"Permission denied." \
"Run deployment with sufficient privileges."

register_error \
"ERR-0008" \
"${CATEGORY_DEPLOYMENT}" \
"${SEVERITY_ERROR}" \
"Deployment interrupted." \
"Retry deployment."

register_error \
"ERR-0009" \
"${CATEGORY_SYSTEM}" \
"${SEVERITY_FATAL}" \
"Unexpected internal framework error." \
"Collect deployment log."

register_error \
"ERR-0010" \
"${CATEGORY_CONFIGURATION}" \
"${SEVERITY_FATAL}" \
"Environment validation failed." \
"Review deployment prerequisites."

###############################################################################
# SSH Errors
###############################################################################

register_error \
"ERR-0101" \
"${CATEGORY_NETWORK}" \
"${SEVERITY_FATAL}" \
"SSH connection failed." \
"Verify IP address, SSH service, username and network."

register_error \
"ERR-0102" \
"${CATEGORY_NETWORK}" \
"${SEVERITY_ERROR}" \
"SSH authentication failed." \
"Verify SSH credentials."

register_error \
"ERR-0103" \
"${CATEGORY_NETWORK}" \
"${SEVERITY_ERROR}" \
"SSH command execution failed." \
"Review remote command output."

###############################################################################
# File Synchronization
###############################################################################

register_error \
"ERR-0201" \
"${CATEGORY_DEPLOYMENT}" \
"${SEVERITY_ERROR}" \
"Project synchronization failed." \
"Verify rsync installation and network."

register_error \
"ERR-0202" \
"${CATEGORY_DEPLOYMENT}" \
"${SEVERITY_ERROR}" \
"Project directory missing." \
"Verify deployment source."

register_error \
"ERR-0203" \
"${CATEGORY_DEPLOYMENT}" \
"${SEVERITY_WARNING}" \
"Old deployment cleanup failed." \
"Manual cleanup may be required."

###############################################################################
# Package Manager
###############################################################################

register_error \
"ERR-0301" \
"${CATEGORY_PACKAGE}" \
"${SEVERITY_FATAL}" \
"APT update failed." \
"Verify internet connectivity and repository configuration."

register_error \
"ERR-0302" \
"${CATEGORY_PACKAGE}" \
"${SEVERITY_FATAL}" \
"APT install failed." \
"Check missing or obsolete packages."

register_error \
"ERR-0303" \
"${CATEGORY_PACKAGE}" \
"${SEVERITY_ERROR}" \
"Required package unavailable." \
"Verify package name for current OS."

###############################################################################
# Python
###############################################################################

register_error \
"ERR-0401" \
"${CATEGORY_PYTHON}" \
"${SEVERITY_FATAL}" \
"Python executable not found." \
"Install supported Python version."

register_error \
"ERR-0402" \
"${CATEGORY_PYTHON}" \
"${SEVERITY_FATAL}" \
"Virtual environment creation failed." \
"Verify python3-venv package."

register_error \
"ERR-0403" \
"${CATEGORY_PYTHON}" \
"${SEVERITY_ERROR}" \
"Pip upgrade failed." \
"Verify internet connectivity."

register_error \
"ERR-0404" \
"${CATEGORY_PYTHON}" \
"${SEVERITY_FATAL}" \
"requirements.txt installation failed." \
"Review pip output."

register_error \
"ERR-0405" \
"${CATEGORY_PYTHON}" \
"${SEVERITY_FATAL}" \
"Python dependency conflict." \
"Review package versions."

###############################################################################
# NumPy
###############################################################################

register_error \
"ERR-0410" \
"${CATEGORY_PYTHON}" \
"${SEVERITY_FATAL}" \
"NumPy installation failed." \
"Verify Python compatibility."

register_error \
"ERR-0411" \
"${CATEGORY_PYTHON}" \
"${SEVERITY_FATAL}" \
"OpenBLAS library missing." \
"Install libopenblas-dev."

register_error \
"ERR-0412" \
"${CATEGORY_PYTHON}" \
"${SEVERITY_FATAL}" \
"NumPy import failed." \
"Verify shared library dependencies."

###############################################################################
# Bluetooth
###############################################################################

register_error \
"ERR-0501" \
"${CATEGORY_BLUETOOTH}" \
"${SEVERITY_FATAL}" \
"Bluetooth service unavailable." \
"Install BlueZ."

register_error \
"ERR-0502" \
"${CATEGORY_BLUETOOTH}" \
"${SEVERITY_ERROR}" \
"Bluetooth adapter not detected." \
"Verify hardware."

register_error \
"ERR-0503" \
"${CATEGORY_BLUETOOTH}" \
"${SEVERITY_ERROR}" \
"Bluetooth restart failed." \
"Review bluetooth.service."

register_error \
"ERR-0504" \
"${CATEGORY_BLUETOOTH}" \
"${SEVERITY_WARNING}" \
"Bluetooth cache cleanup failed." \
"Manual cleanup recommended."

###############################################################################
# NetworkManager
###############################################################################

register_error \
"ERR-0601" \
"${CATEGORY_SERVICE}" \
"${SEVERITY_FATAL}" \
"NetworkManager service unavailable." \
"Install NetworkManager."

register_error \
"ERR-0602" \
"${CATEGORY_SERVICE}" \
"${SEVERITY_ERROR}" \
"nmcli unavailable." \
"Verify NetworkManager installation."

###############################################################################
# Systemd
###############################################################################

register_error \
"ERR-0701" \
"${CATEGORY_SERVICE}" \
"${SEVERITY_FATAL}" \
"Service file creation failed." \
"Verify permissions."

register_error \
"ERR-0702" \
"${CATEGORY_SERVICE}" \
"${SEVERITY_FATAL}" \
"systemd daemon reload failed." \
"Review system logs."

register_error \
"ERR-0703" \
"${CATEGORY_SERVICE}" \
"${SEVERITY_FATAL}" \
"Service enable failed." \
"Verify service configuration."

register_error \
"ERR-0704" \
"${CATEGORY_SERVICE}" \
"${SEVERITY_FATAL}" \
"Service startup failed." \
"Inspect journalctl output."

register_error \
"ERR-0705" \
"${CATEGORY_SERVICE}" \
"${SEVERITY_ERROR}" \
"Service health check failed." \
"Review application logs."

###############################################################################
# Deployment
###############################################################################

register_error \
"ERR-0801" \
"${CATEGORY_DEPLOYMENT}" \
"${SEVERITY_FATAL}" \
"Deployment verification failed." \
"Run diagnostics."

register_error \
"ERR-0802" \
"${CATEGORY_DEPLOYMENT}" \
"${SEVERITY_ERROR}" \
"Rollback initiated." \
"Inspect deployment log."

register_error \
"ERR-0803" \
"${CATEGORY_DEPLOYMENT}" \
"${SEVERITY_FATAL}" \
"Rollback failed." \
"Manual recovery required."

register_error \
"ERR-0804" \
"${CATEGORY_DEPLOYMENT}" \
"${SEVERITY_ERROR}" \
"Health check timeout." \
"Verify application startup."

register_error \
"ERR-0805" \
"${CATEGORY_DEPLOYMENT}" \
"${SEVERITY_WARNING}" \
"Deployment completed with warnings." \
"Review deployment summary."

###############################################################################
# Error Lookup
###############################################################################

error_exists() {

    local code="$1"

    [[ -n "${ERROR_MESSAGE[$code]:-}" ]]

}

###############################################################################
# Get Error Message
###############################################################################

error_message() {

    local code="$1"

    echo "${ERROR_MESSAGE[$code]:-Unknown Error}"

}

###############################################################################
# Get Error Category
###############################################################################

error_category() {

    local code="$1"

    echo "${ERROR_CATEGORY[$code]:-${CATEGORY_UNKNOWN}}"

}

###############################################################################
# Get Severity
###############################################################################

error_severity() {

    local code="$1"

    echo "${ERROR_SEVERITY[$code]:-${SEVERITY_ERROR}}"

}

###############################################################################
# Get Recovery Hint
###############################################################################

error_hint() {

    local code="$1"

    echo "${ERROR_HINT[$code]:-No recovery information available.}"

}

###############################################################################
# Pretty Print Error
###############################################################################

print_error() {

    local code="$1"

    cat <<EOF

====================================================================

Error Code   : ${code}

Category     : $(error_category "${code}")

Severity     : $(error_severity "${code}")

Description  : $(error_message "${code}")

Recovery     : $(error_hint "${code}")

====================================================================

EOF

}

###############################################################################
# Compact Error
###############################################################################

error_summary() {

    local code="$1"

    printf "[%s] %s\n" \
        "${code}" \
        "$(error_message "${code}")"

}

###############################################################################
# Fatal Error Helper
###############################################################################

fatal_error() {

    local code="$1"

    print_error "${code}"

    exit 1

}

###############################################################################
# Warning Helper
###############################################################################

warning_error() {

    local code="$1"

    error_summary "${code}"

}

###############################################################################
# Registry Information
###############################################################################

error_count() {

    echo "${#ERROR_MESSAGE[@]}"

}

###############################################################################
# List All Registered Errors
###############################################################################

list_errors() {

    local code

    for code in "${!ERROR_MESSAGE[@]}"
    do

        printf "%-10s %-15s %-10s %s\n" \
            "${code}" \
            "${ERROR_CATEGORY[$code]}" \
            "${ERROR_SEVERITY[$code]}" \
            "${ERROR_MESSAGE[$code]}"

    done | sort

}

###############################################################################
# Export Public API
###############################################################################

export -f \
    register_error \
    error_exists \
    error_message \
    error_category \
    error_severity \
    error_hint \
    print_error \
    error_summary \
    fatal_error \
    warning_error \
    error_count \
    list_errors

###############################################################################
# Self Test
###############################################################################

errors_self_test() {

    error_exists "ERR-0001" || return 1

    error_exists "ERR-0101" || return 1

    error_exists "ERR-0301" || return 1

    error_exists "ERR-0701" || return 1

    return 0

}