#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : files.sh
# Version     : 1.0.0
#
# Description :
# File and directory validation utilities.
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
# Validate File Exists
###############################################################################

validate_file() {

    local file="$1"

    if [[ -f "${file}" ]]
    then

        log_success "File found : ${file}"

        return 0

    fi

    log_error "File not found : ${file}"

    return 1

}

###############################################################################
# Validate Directory Exists
###############################################################################

validate_directory() {

    local directory="$1"

    if [[ -d "${directory}" ]]
    then

        log_success "Directory found : ${directory}"

        return 0

    fi

    log_error "Directory not found : ${directory}"

    return 1

}

###############################################################################
# Validate Executable
###############################################################################

validate_executable() {

    local file="$1"

    if [[ -x "${file}" ]]
    then

        log_success "Executable : ${file}"

        return 0

    fi

    log_error "Not executable : ${file}"

    return 1

}

###############################################################################
# Validate Read Permission
###############################################################################

validate_readable() {

    local file="$1"

    if [[ -r "${file}" ]]
    then

        log_success "Readable : ${file}"

        return 0

    fi

    log_error "Not readable : ${file}"

    return 1

}

###############################################################################
# Validate Write Permission
###############################################################################

validate_writable() {

    local file="$1"

    if [[ -w "${file}" ]]
    then

        log_success "Writable : ${file}"

        return 0

    fi

    log_error "Not writable : ${file}"

    return 1

}

###############################################################################
# Validate Empty Directory
###############################################################################

validate_directory_not_empty() {

    local directory="$1"

    if [[ -d "${directory}" ]] && [[ -n "$(ls -A "${directory}")" ]]
    then

        log_success "Directory contains files : ${directory}"

        return 0

    fi

    log_error "Directory is empty : ${directory}"

    return 1

}

###############################################################################
# Validate Symbolic Link
###############################################################################

validate_symlink() {

    local link="$1"

    if [[ -L "${link}" ]]
    then

        log_success "Symbolic link verified : ${link}"

        return 0

    fi

    log_error "Symbolic link missing : ${link}"

    return 1

}

###############################################################################
# Validate Multiple Files
###############################################################################

validate_files() {

    local failed=0

    local file

    for file in "$@"
    do

        validate_file "${file}" || failed=1

    done

    return "${failed}"

}

###############################################################################
# Validate Multiple Directories
###############################################################################

validate_directories() {

    local failed=0

    local directory

    for directory in "$@"
    do

        validate_directory "${directory}" || failed=1

    done

    return "${failed}"

}

###############################################################################
# Public API
###############################################################################

export -f \
    validate_file \
    validate_directory \
    validate_executable \
    validate_readable \
    validate_writable \
    validate_directory_not_empty \
    validate_symlink \
    validate_files \
    validate_directories