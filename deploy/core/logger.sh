#!/usr/bin/env bash
###############################################################################
#                                                                             #
#                    TinQa Deployment Framework v1.0.0                        #
#                                                                             #
#  File        : logger.sh                                                    #
#  Description : Central Logging & Execution Engine                           #
#                                                                             #
#  Responsibilities                                                           #
#  -------------------------------------------------------------------------  #
#  • Console Logging                                                          #
#  • File Logging                                                             #
#  • Colored Output                                                           #
#  • Deployment Statistics                                                    #
#  • Module Lifecycle                                                         #
#  • Command Execution Wrapper                                                #
#  • Deployment Summary                                                       #
#                                                                             #
###############################################################################

set -Eeuo pipefail

###############################################################################
# GLOBAL VARIABLES
###############################################################################

SUCCESS_COUNT=0
WARNING_COUNT=0
ERROR_COUNT=0

ERROR_MESSAGES=()
WARNING_MESSAGES=()

MODULE_COUNT=0
STEP_COUNT=0

CURRENT_MODULE=""
CURRENT_STEP=""
CURRENT_ERROR_CODE=""

DEPLOYMENT_START_TIME=0
DEPLOYMENT_END_TIME=0

MODULE_START_TIME=0
STEP_START_TIME=0

LOG_FILE=""

###############################################################################
# PRIVATE FUNCTIONS
###############################################################################

###############################################################################
# Returns current timestamp
#
# Example
# 18:42:31
###############################################################################

_timestamp() {

    date +"%H:%M:%S"

}

###############################################################################
# Returns current datetime
###############################################################################

_datetime() {

    date +"%Y-%m-%d %H:%M:%S"

}

###############################################################################
# Returns today's date
###############################################################################

_today() {

    date +"%Y-%m-%d"

}

###############################################################################
# Formats duration
#
# 5
# -> 5 sec
#
# 95
# -> 1 min 35 sec
#
# 3725
# -> 1 hr 02 min 05 sec
###############################################################################

_format_duration() {

    local total="${1:-0}"

    if (( total < 60 )); then

        printf "%d sec" "${total}"

        return

    fi

    if (( total < 3600 )); then

        printf "%d min %02d sec" \
            "$((total/60))" \
            "$((total%60))"

        return

    fi

    printf "%d hr %02d min %02d sec" \
        "$((total/3600))" \
        "$(((total%3600)/60))" \
        "$((total%60))"

}

###############################################################################
# Removes terminal color codes before writing logfile
###############################################################################

_strip_colors() {

    printf "%s" "$1" |
        sed -E 's/\x1B\[[0-9;]*[mK]//g'

}

###############################################################################
# Writes plain text into deployment logfile
###############################################################################

_write_log() {

    local message="$1"

    [[ -z "${LOG_FILE}" ]] && return

    printf "%s\n" \
        "$(_strip_colors "$message")" \
        >> "${LOG_FILE}"

}

###############################################################################
# Emits message to terminal and logfile
###############################################################################

_emit() {

    local message="$1"

    printf "%b\n" "${message}"

    _write_log "${message}"

}

###############################################################################
# Increments deployment counters
###############################################################################

_increment_counter() {

    case "$1" in
        success)
            ((++SUCCESS_COUNT))
            ;;
        warning)
            ((++WARNING_COUNT))
            ;;
        error)
            ((++ERROR_COUNT))
            ;;
    esac
}

###############################################################################
# Generates step id
#
# STEP-001
# STEP-002
###############################################################################

_next_step() {

    ((++STEP_COUNT))

    printf "STEP-%03d" "${STEP_COUNT}"

}

###############################################################################
# Generates module id
#
# MODULE-001
###############################################################################

_next_module() {

    ((++MODULE_COUNT))

    printf "MODULE-%02d" "${MODULE_COUNT}"

}

###############################################################################
# PUBLIC LOGGING API
###############################################################################
###############################################################################
# Prints a separator line
###############################################################################

log_line() {

    _emit "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

}

###############################################################################
# Prints a titled section
#
# Example:
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Python Environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
###############################################################################

log_section() {

    local title="$1"

    _emit ""

    log_line

    _emit " ${title}"

    log_line

    _emit ""

}

###############################################################################
# INFO
###############################################################################

log_info() {

    local message="$1"

    _emit "${BLUE}[INFO]${RESET} ${message}"

}

###############################################################################
# SUCCESS
###############################################################################

log_success() {

    local message="$1"

    _increment_counter success

    _emit "${GREEN}[ OK ]${RESET} ${message}"

}

###############################################################################
# WARNING
###############################################################################

log_warning() {

    local message="$1"

    _increment_counter warning

    WARNING_MESSAGES+=("${message}")

    _emit "${YELLOW}[WARN]${RESET} ${message}"

}

###############################################################################
# ERROR
###############################################################################

log_error() {

    local message="$1"

    _increment_counter error

    ERROR_MESSAGES+=("${message}")

    _emit "${RED}[FAIL]${RESET} ${message}"

}

###############################################################################
# DEBUG
#
# Printed only when DEBUG_MODE=1
###############################################################################

log_debug() {

    local message="$1"

    [[ "${DEBUG_MODE:-0}" == "1" ]] || return 0

    _emit "${CYAN}[DBG ]${RESET} ${message}"

}

###############################################################################
# Starts a deployment module
#
# Example:
#
# MODULE-01
# Python Environment
###############################################################################

module_begin() {

    CURRENT_MODULE="$1"

    MODULE_START_TIME=$(date +%s)

    local module_id

    module_id="$(_next_module)"

    log_section "${module_id} : ${CURRENT_MODULE}"

}

###############################################################################
# Ends current deployment module
###############################################################################

module_end() {

    local end_time

    local duration

    end_time=$(date +%s)

    duration=$((end_time-MODULE_START_TIME))

    log_success "Module Completed"

    log_info "Duration : $(_format_duration "${duration}")"

    _emit ""

}

###############################################################################
# Prints framework banner
###############################################################################

logger_banner() {

    log_line

    _emit " TinQa Deployment Framework"

    log_line

    _emit ""

    printf "%-18s : %s\n" "Framework" "${FRAMEWORK_VERSION}"
    printf "%-18s : %s\n" "Project" "${PROJECT_NAME}"
    printf "%-18s : %s\n" "Target" "${SSH_TARGET}"
    printf "%-18s : %s\n" "Started" "$(_datetime)"

    _write_log "Framework         : ${FRAMEWORK_VERSION}"
    _write_log "Project           : ${PROJECT_NAME}"
    _write_log "Target            : ${SSH_TARGET}"
    _write_log "Started           : $(_datetime)"

    _emit ""

}

###############################################################################
# Initializes Logger
###############################################################################

init_logger() {

    DEPLOYMENT_START_TIME=$(date +%s)

    mkdir -p "${LOG_DIRECTORY}"

    LOG_FILE="${LOG_DIRECTORY}/deployment_$(date +%Y%m%d_%H%M%S).log"

    touch "${LOG_FILE}"

    logger_banner

}

###############################################################################
# Executes any deployment step
#
# Usage:
#
# run \
#     "Installing Python" \
#     sudo apt install -y python3
#
# OR
#
# run \
#     "Checking Bluetooth" \
#     "systemctl status bluetooth"
#
###############################################################################

run() {

    local description="$1"
    shift

    local step_id
    local start_time
    local end_time
    local duration
    local exit_code

    local output_file

    step_id="$(_next_step)"

    start_time=$(date +%s)

    log_line

    log_info "${step_id}"

    log_info "${description}"

    log_debug "Working Directory : $(pwd)"

    ###############################################################
    # Determine command style
    ###############################################################

    local command_string=""

    if [[ $# -eq 1 ]]; then

        command_string="$1"

    else

        printf -v command_string "%q " "$@"

    fi

    log_debug "Command :"

    log_debug "${command_string}"

    output_file=$(mktemp)

    ###############################################################
    # Execute command
    ###############################################################

    if [[ $# -eq 1 ]]; then

        bash -c "${command_string}" \
            > >(tee "${output_file}") \
            2> >(tee -a "${output_file}" >&2)

        exit_code=$?

    else

        "$@" \
            > >(tee "${output_file}") \
            2> >(tee -a "${output_file}" >&2)

        exit_code=$?

    fi

    end_time=$(date +%s)

    duration=$((end_time-start_time))

    ###############################################################
    # Print Result
    ###############################################################

    if [[ ${exit_code} -eq 0 ]]; then

        log_success "Completed"

    else

        log_error "Failed"

    fi

    log_info "Duration : $(_format_duration "${duration}")"

    log_info "Exit Code : ${exit_code}"

    ###############################################################
    # Save Output
    ###############################################################

    if [[ -s "${output_file}" ]]; then

        _emit ""

        _emit "Output"

        log_line

        while IFS= read -r line
        do
            _write_log "${line}"
        done < "${output_file}"

    fi

    rm -f "${output_file}"

    ###############################################################
    # Statistics
    ###############################################################

    if [[ ${exit_code} -ne 0 ]]; then

        CURRENT_ERROR_CODE="${step_id}"

    fi

    _emit ""

    return "${exit_code}"

}

###############################################################################
# Execute a non-critical command
#
# Never aborts deployment.
###############################################################################

run_optional() {

    if ! run "$@"; then

        log_warning "Continuing deployment..."

        return 0

    fi

}

###############################################################################
# Retry wrapper
#
# Example:
#
# retry 5 run \
#   "Installing Packages" \
#   sudo apt install -y python3
#
###############################################################################

retry() {

    local retries="$1"

    shift

    local count=1

    while true
    do

        if "$@"; then

            return 0

        fi

        if (( count >= retries )); then

            log_error "Maximum retry count reached."

            return 1

        fi

        log_warning "Retry ${count}/${retries}"

        sleep 2

        ((++count))

    done

}

###############################################################################
# Initializes Logger
###############################################################################

init_logger() {

    DEPLOYMENT_START_TIME=$(date +%s)

    mkdir -p "${LOG_DIRECTORY}"

    LOG_FILE="${LOG_DIRECTORY}/deployment_$(date +"%Y%m%d_%H%M%S").log"

    touch "${LOG_FILE}"

    log_line
    _emit "               TinQa Deployment Framework"
    _emit "                     Version ${LOGGER_VERSION}"
    log_line
    _emit ""

    _emit "Project      : ${PROJECT_NAME}"
    _emit "Target       : ${SSH_TARGET}"
    _emit "Started      : $(_datetime)"
    _emit "Log File     : ${LOG_FILE}"

    _emit ""

}

###############################################################################
# Prints Deployment Summary
###############################################################################

_print_summary() {

    DEPLOYMENT_END_TIME=$(date +%s)

    local duration

    duration=$((DEPLOYMENT_END_TIME-DEPLOYMENT_START_TIME))

    local total

    total=$((SUCCESS_COUNT+WARNING_COUNT+ERROR_COUNT))

    local success_rate=100

    if [[ ${total} -gt 0 ]]; then

        success_rate=$((SUCCESS_COUNT*100/total))

    fi

    log_section "Deployment Summary"

    printf "%-25s %s\n" "Modules Executed" "${MODULE_COUNT}" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Steps Executed" "${STEP_COUNT}" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Successful Steps" "${SUCCESS_COUNT}" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Warnings" "${WARNING_COUNT}" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Errors" "${ERROR_COUNT}" | tee -a "${LOG_FILE}"

    printf "%-25s %s%%\n" "Success Rate" "${success_rate}" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Duration" "$(_format_duration "${duration}")" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Log File" "${LOG_FILE}" | tee -a "${LOG_FILE}"

    _emit ""

}

###############################################################################
# Prints System Information
###############################################################################

_print_environment() {

    log_section "Environment"

    printf "%-25s %s\n" "Hostname" "$(hostname)" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Kernel" "$(uname -r)" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Architecture" "$(uname -m)" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Shell" "${BASH_VERSION}" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "User" "$(whoami)" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Working Directory" "$(pwd)" | tee -a "${LOG_FILE}"

    printf "%-25s %s\n" "Framework Version" "${LOGGER_VERSION}" | tee -a "${LOG_FILE}"

    _emit ""

}

###############################################################################
# Initialize Logger
###############################################################################

initialize_logger() {

    mkdir -p "${LOG_DIRECTORY}"

    LOG_FILE="${LOG_DIRECTORY}/deployment_$(date +%Y%m%d_%H%M%S).log"

    touch "${LOG_FILE}"

    export LOG_FILE

    return 0
}

###############################################################################
# Finish Logger
###############################################################################

finish_logger() {

    _print_summary

    _print_environment

    if [[ ${ERROR_COUNT} -eq 0 ]]; then

        log_line

        log_success "Deployment Completed Successfully"

        log_line

    else

        log_line

        log_error "Deployment Finished With Errors"

        log_line

    fi

    _emit ""

}

###############################################################################
# Panic
#
# Prints fatal error and exits.
###############################################################################

panic() {

    local message="$1"

    log_error "${message}"

    finish_logger

    exit 1

}

###############################################################################
# Assert
#
# Example:
#
# assert command -v python3
#
###############################################################################

assert() {

    "$@"

    local rc=$?

    if [[ ${rc} -ne 0 ]]; then

        panic "Assertion Failed : $*"
    fi

}

###############################################################################
# Export Public API
###############################################################################

export -f \
    init_logger \
    finish_logger \
    module_begin \
    initialize_logger \
    module_end \
    run \
    run_optional \
    retry \
    panic \
    assert \
    log_info \
    log_success \
    log_warning \
    log_error \
    log_debug