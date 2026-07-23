#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Error Management
###############################################################################

set -Eeuo pipefail

###############################################################################
# Error Codes
###############################################################################

readonly E001="Unknown Error"

readonly E100="Configuration Error"
readonly E101="Configuration File Missing"
readonly E102="Invalid Configuration"

readonly E200="SSH Connection Failed"
readonly E201="SSH Authentication Failed"
readonly E202="SSH Command Failed"

readonly E300="Project Transfer Failed"

readonly E400="APT Update Failed"
readonly E401="APT Package Installation Failed"

readonly E500="Virtual Environment Creation Failed"
readonly E501="Python Package Installation Failed"

readonly E600="Bluetooth Configuration Failed"

readonly E700="System Validation Failed"
readonly E701="Python Validation Failed"
readonly E702="Network Validation Failed"
readonly E703="Bluetooth Validation Failed"
readonly E704="Runtime Validation Failed"

readonly E800="Systemd Service Creation Failed"
readonly E801="Systemd Service Start Failed"

readonly E900="Rollback Failed"

###############################################################################
# Runtime State
###############################################################################

CURRENT_ERROR_CODE="$E001"
CURRENT_ERROR_MESSAGE=""
CURRENT_FAILED_COMMAND=""
CURRENT_FAILED_LINE=0
CURRENT_EXIT_CODE=0

###############################################################################
# Helpers
###############################################################################

set_error() {

    CURRENT_ERROR_CODE="$1"
    CURRENT_ERROR_MESSAGE="$2"

}

###############################################################################
# Error Handler
###############################################################################

handle_error() {

    local line="$1"
    local command="$2"
    local exit_code="$3"

    CURRENT_FAILED_LINE="$line"
    CURRENT_FAILED_COMMAND="$command"
    CURRENT_EXIT_CODE="$exit_code"

    log_line

    log_error "Deployment Failed"

    log_plain ""

    log_plain "Error Code    : ${CURRENT_ERROR_CODE}"
    log_plain "Description   : ${CURRENT_ERROR_MESSAGE}"
    log_plain "Exit Code     : ${CURRENT_EXIT_CODE}"
    log_plain "Line Number   : ${CURRENT_FAILED_LINE}"
    log_plain "Command"

    log_plain "    ${CURRENT_FAILED_COMMAND}"

    log_plain ""

    log_plain "Stack Trace"

    local i

    for ((i=${#FUNCNAME[@]}-1; i>=1; i--)); do
        printf "    • %s (%s:%s)\n" \
            "${FUNCNAME[$i]}" \
            "${BASH_SOURCE[$i]}" \
            "${BASH_LINENO[$((i-1))]}" \
            | tee /dev/fd/3
    done

    log_plain ""

    log_plain "Deployment aborted."

    log_line

    finish_logger

    exit "$CURRENT_EXIT_CODE"

}

###############################################################################
# Assertions
###############################################################################

assert_file_exists() {

    local file="$1"

    [[ -f "$file" ]] && return

    set_error "$E101" "Required file not found"

    return 1

}

assert_directory_exists() {

    local directory="$1"

    [[ -d "$directory" ]] && return

    set_error "$E100" "Required directory not found"

    return 1

}

assert_command_exists() {

    local command="$1"

    command -v "$command" >/dev/null 2>&1 && return

    set_error "$E100" "Missing command: ${command}"

    return 1

}

###############################################################################
# End
###############################################################################