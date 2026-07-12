#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : runtime.sh
# Version     : 1.0.0
#
# Description :
# Runtime environment validation utilities.
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

###############################################################################
# Validate Current User
###############################################################################

validate_user() {

    log_info "Checking current user..."

    if [[ "$(id -un)" == "${PROJECT_USER}" ]]
    then

        log_success "Running as ${PROJECT_USER}."

        return 0

    fi

    log_error "Expected user: ${PROJECT_USER}"

    return 1

}

###############################################################################
# Validate Current Working Directory
###############################################################################

validate_working_directory() {

    log_info "Checking working directory..."

    if [[ "$(pwd)" == "${PROJECT_ROOT}" ]]
    then

        log_success "Working directory verified."

        return 0

    fi

    log_error "Unexpected working directory."

    return 1

}

###############################################################################
# Validate Environment Variables
###############################################################################

validate_environment() {

    log_info "Checking required environment variables..."

    local failed=0

    local variables=(

        PROJECT_ROOT
        PROJECT_USER
        VENV_DIRECTORY
        PYTHON_BINARY

    )

    local variable

    for variable in "${variables[@]}"
    do

        if [[ -n "${!variable:-}" ]]
        then

            log_success "${variable} is set."

        else

            log_error "${variable} is missing."

            failed=1

        fi

    done

    return "${failed}"

}

###############################################################################
# Validate PATH
###############################################################################

validate_path() {

    log_info "Checking PATH..."

    if [[ ":${PATH}:" == *":${VENV_DIRECTORY}/bin:"* ]]
    then

        log_success "Virtual environment is in PATH."

        return 0

    fi

    log_warning "Virtual environment not present in PATH."

    return 1

}

###############################################################################
# Validate Disk Space
###############################################################################

validate_disk_space() {

    log_info "Checking available disk space..."

    local available

    available=$(df -Pm "${PROJECT_ROOT}" | awk 'NR==2 {print $4}')

    if (( available >= 1024 ))
    then

        log_success "${available} MB available."

        return 0

    fi

    log_error "Insufficient disk space."

    return 1

}

###############################################################################
# Validate Memory
###############################################################################

validate_memory() {

    log_info "Checking available memory..."

    local available

    available=$(free -m | awk '/^Mem:/ {print $7}')

    if (( available >= 256 ))
    then

        log_success "${available} MB available."

        return 0

    fi

    log_warning "Low available memory."

    return 1

}

###############################################################################
# Validate Uptime
###############################################################################

validate_uptime() {

    log_info "Checking system uptime..."

    uptime -p >/dev/null

    log_success "System uptime available."

}

###############################################################################
# Validate Runtime
###############################################################################

validate_runtime() {

    validate_environment

    validate_user

    validate_working_directory

    validate_path

    validate_disk_space

    validate_memory

    validate_uptime

}

###############################################################################
# Public API
###############################################################################

export -f \
    validate_user \
    validate_working_directory \
    validate_environment \
    validate_path \
    validate_disk_space \
    validate_memory \
    validate_uptime \
    validate_runtime