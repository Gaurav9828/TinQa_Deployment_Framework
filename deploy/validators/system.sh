#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : system.sh
# Version     : 1.0.0
#
# Description :
# Operating system validation utilities.
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
# Validate Operating System
###############################################################################

validate_os() {

    log_info "Checking operating system..."

    if [[ -f "/etc/os-release" ]]
    then

        log_success "Operating system detected."

        return 0

    fi

    log_error "Unable to detect operating system."

    return 1

}

###############################################################################
# Validate Architecture
###############################################################################

validate_architecture() {

    log_info "Checking CPU architecture..."

    local architecture

    architecture="$(uname -m)"

    case "${architecture}" in

        aarch64|armv7l|armv6l)

            log_success "Architecture supported : ${architecture}"

            return 0
            ;;

    esac

    log_error "Unsupported architecture : ${architecture}"

    return 1

}

###############################################################################
# Validate Kernel
###############################################################################

validate_kernel() {

    log_info "Checking Linux kernel..."

    uname -r >/dev/null

    log_success "Kernel detected : $(uname -r)"

}

###############################################################################
# Validate Hostname
###############################################################################

validate_hostname() {

    log_info "Checking hostname..."

    hostname >/dev/null

    log_success "Hostname : $(hostname)"

}

###############################################################################
# Validate Sudo
###############################################################################

validate_sudo() {

    log_info "Checking sudo privileges..."

    if sudo -n true 2>/dev/null
    then

        log_success "Sudo privileges verified."

        return 0

    fi

    log_error "Passwordless sudo not available."

    return 1

}

###############################################################################
# Validate Required Commands
###############################################################################

validate_commands() {

    log_info "Checking required system commands..."

    local failed=0

    local commands=(

        bash
        systemctl
        python3
        pip3
        rsync
        git
        sed
        awk
        grep
        find
        stat
        df
        free
        ip
        bluetoothctl

    )

    local command

    for command in "${commands[@]}"
    do

        if command -v "${command}" >/dev/null 2>&1
        then

            log_success "Found : ${command}"

        else

            log_error "Missing : ${command}"

            failed=1

        fi

    done

    return "${failed}"

}

###############################################################################
# Validate Time Synchronization
###############################################################################

validate_time_sync() {

    log_info "Checking system time..."

    timedatectl status >/dev/null

    log_success "System time available."

}

###############################################################################
# Validate System
###############################################################################

validate_system() {

    validate_os

    validate_architecture

    validate_kernel

    validate_hostname

    validate_sudo

    validate_commands

    validate_time_sync

}

###############################################################################
# Public API
###############################################################################

export -f \
    validate_os \
    validate_architecture \
    validate_kernel \
    validate_hostname \
    validate_sudo \
    validate_commands \
    validate_time_sync \
    validate_system