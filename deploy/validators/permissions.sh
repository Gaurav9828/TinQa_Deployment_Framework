#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : permissions.sh
# Version     : 1.0.0
#
# Description :
# File ownership and permission validation utilities.
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
# Validate Owner
###############################################################################

validate_owner() {

    local file="$1"

    local owner="$2"

    if [[ "$(stat -c '%U' "${file}")" == "${owner}" ]]
    then

        log_success "Owner verified : ${file}"

        return 0

    fi

    log_error "Owner mismatch : ${file}"

    return 1

}

###############################################################################
# Validate Group
###############################################################################

validate_group() {

    local file="$1"

    local group="$2"

    if [[ "$(stat -c '%G' "${file}")" == "${group}" ]]
    then

        log_success "Group verified : ${file}"

        return 0

    fi

    log_error "Group mismatch : ${file}"

    return 1

}

###############################################################################
# Validate Permissions
###############################################################################

validate_permissions() {

    local file="$1"

    local permission="$2"

    if [[ "$(stat -c '%a' "${file}")" == "${permission}" ]]
    then

        log_success "Permissions verified : ${file}"

        return 0

    fi

    log_error "Permission mismatch : ${file}"

    return 1

}

###############################################################################
# Validate Executable
###############################################################################

validate_executable_permission() {

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

validate_read_permission() {

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

validate_write_permission() {

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
# Validate Directory Ownership
###############################################################################

validate_directory_owner() {

    local directory="$1"

    local owner="$2"

    validate_owner "${directory}" "${owner}"

}

###############################################################################
# Validate Directory Permissions
###############################################################################

validate_directory_permissions() {

    local directory="$1"

    local permission="$2"

    validate_permissions "${directory}" "${permission}"

}

###############################################################################
# Validate Multiple Files
###############################################################################

validate_permission_set() {

    local permission="$1"

    shift

    local file

    local failed=0

    for file in "$@"
    do

        validate_permissions "${file}" "${permission}" || failed=1

    done

    return "${failed}"

}

###############################################################################
# Public API
###############################################################################

export -f \
    validate_owner \
    validate_group \
    validate_permissions \
    validate_executable_permission \
    validate_read_permission \
    validate_write_permission \
    validate_directory_owner \
    validate_directory_permissions \
    validate_permission_set