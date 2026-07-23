#!/usr/bin/env bash
###############################################################################
# TinQa Deployment Framework
# -----------------------------------------------------------------------------
# File        : logger.sh
# Version     : 1.0.0
# Description : Centralized logging, timing, execution and reporting library.
#
# Responsibilities
#   - Console logging
#   - File logging
#   - Colored output
#   - Module lifecycle
#   - Step lifecycle
#   - Command execution wrapper
#   - Deployment summary
#   - Statistics
#
# This file MUST NEVER:
#   - Execute deployment logic
#   - Install packages
#   - Copy files
#   - Configure services
#   - Exit the deployment
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# GLOBAL COUNTERS
###############################################################################

SUCCESS_COUNT=0
WARNING_COUNT=0
ERROR_COUNT=0

MODULE_COUNT=0
STEP_COUNT=0

###############################################################################
# TIMERS
###############################################################################

DEPLOYMENT_START_TIME=0
DEPLOYMENT_END_TIME=0

MODULE_START_TIME=0
STEP_START_TIME=0

###############################################################################
# CURRENT CONTEXT
###############################################################################

CURRENT_MODULE=""
CURRENT_STEP=""
CURRENT_ERROR_CODE=""

###############################################################################
# LOG FILE
###############################################################################

LOG_DIRECTORY=""
LOG_FILE=""

###############################################################################
# PRIVATE FUNCTIONS
###############################################################################

###############################################################################
# _timestamp
#
# Returns:
#   Current time in HH:MM:SS
###############################################################################

_timestamp() {

    date +"%H:%M:%S"

}

###############################################################################
# _date
#
# Returns:
#   Current date
###############################################################################

_date() {

    date +"%Y-%m-%d"

}

###############################################################################
# _datetime
#
# Returns:
#   Current timestamp
###############################################################################

_datetime() {

    date +"%Y-%m-%d %H:%M:%S"

}

###############################################################################
# _format_duration
#
# Parameters:
#   Seconds
#
# Returns:
#   Human readable duration
###############################################################################

_format_duration() {

    local seconds="${1:-0}"

    if (( seconds < 60 )); then
        printf "%ds" "$seconds"
        return
    fi

    if (( seconds < 3600 )); then
        printf "%dm %02ds" \
            "$((seconds/60))" \
            "$((seconds%60))"
        return
    fi

    printf "%dh %02dm %02ds" \
        "$((seconds/3600))" \
        "$(((seconds%3600)/60))" \
        "$((seconds%60))"

}

###############################################################################
# _strip_colors
###############################################################################

_strip_colors() {

    printf "%s" "$1" |
        sed -E 's/\x1B\[[0-9;]*[mK]//g'

}

###############################################################################
# _write_log
###############################################################################

_write_log() {

    local message="$1"

    [[ -z "${LOG_FILE}" ]] && return 0

    printf "%s\n" \
        "$(_strip_colors "$message")" \
        >> "${LOG_FILE}"

}

###############################################################################
# _emit
#
# Prints to terminal
# Writes to log file
###############################################################################

_emit() {

    local message="$1"

    printf "%b\n" "$message"

    _write_log "$message"

}

###############################################################################
# _increment_counter
###############################################################################

_increment_counter() {

    case "$1" in

        success)

            SUCCESS_COUNT=$((SUCCESS_COUNT+1))

            ;;

        warning)

            WARNING_COUNT=$((WARNING_COUNT+1))

            ;;

        error)

            ERROR_COUNT=$((ERROR_COUNT+1))

            ;;

    esac

}

###############################################################################
# PUBLIC FUNCTIONS
###############################################################################

###############################################################################
# init_logger
###############################################################################

init_logger() {

    DEPLOYMENT_START_TIME=$(date +%s)

    LOG_DIRECTORY="${PROJECT_ROOT}/logs"

    mkdir -p "${LOG_DIRECTORY}"

    LOG_FILE="${LOG_DIRECTORY}/deployment_$(
        date +"%Y%m%d_%H%M%S"
    ).log"

    touch "${LOG_FILE}"

    log_line

    _emit " TinQa Deployment Framework"

    log_line

    _emit ""

    _emit " Framework Version : ${FRAMEWORK_VERSION}"

    _emit " Project           : ${PROJECT_NAME}"

    _emit " Target            : ${SSH_TARGET}"

    _emit " Started           : $(_datetime)"

    _emit ""

}

