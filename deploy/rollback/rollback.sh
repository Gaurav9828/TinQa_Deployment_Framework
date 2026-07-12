#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : rollback.sh
# Version     : 1.0.0
#
# Description :
# Rollback manager.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Dependencies
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${DEPLOY_ROOT}/core/logger.sh"
source "${DEPLOY_ROOT}/core/utils.sh"

source "${DEPLOY_ROOT}/config/files.conf"
source "${DEPLOY_ROOT}/config/services.conf"

###############################################################################
# Backup Registry
###############################################################################

BACKUP_ITEMS=()

###############################################################################
# Register Backup
###############################################################################

register_backup() {

    local source="$1"
    local backup="$2"

    BACKUP_ITEMS+=("${source}|${backup}")

}

###############################################################################
# Backup File
###############################################################################

backup_file() {

    local file="$1"

    [[ -f "${file}" ]] || return 0

    mkdir -p "${ROLLBACK_DIRECTORY}"

    local backup="${ROLLBACK_DIRECTORY}/$(basename "${file}").bak"

    cp -a "${file}" "${backup}"

    register_backup "${file}" "${backup}"

    log_info "Backup created: ${file}"

}

###############################################################################
# Backup Directory
###############################################################################

backup_directory() {

    local directory="$1"

    [[ -d "${directory}" ]] || return 0

    mkdir -p "${ROLLBACK_DIRECTORY}"

    local backup="${ROLLBACK_DIRECTORY}/$(basename "${directory}")"

    cp -a "${directory}" "${backup}"

    register_backup "${directory}" "${backup}"

    log_info "Backup created: ${directory}"

}

###############################################################################
# Restore Item
###############################################################################

restore_item() {

    local source="$1"

    local backup="$2"

    [[ -e "${backup}" ]] || return 0

    rm -rf "${source}"

    cp -a "${backup}" "${source}"

    log_success "Restored: ${source}"

}

###############################################################################
# Rollback
###############################################################################

perform_rollback() {

    log_warning "Rollback started."

    local entry

    for ((i=${#BACKUP_ITEMS[@]}-1; i>=0; i--))
    do

        entry="${BACKUP_ITEMS[$i]}"

        IFS='|' read -r source backup <<< "${entry}"

        restore_item "${source}" "${backup}"

    done

    log_success "Rollback completed."

}

###############################################################################
# Cleanup Rollback
###############################################################################

cleanup_rollback() {

    [[ -d "${ROLLBACK_DIRECTORY}" ]] || return 0

    rm -rf "${ROLLBACK_DIRECTORY}"

    log_info "Rollback cache removed."

}

###############################################################################
# Rollback Summary
###############################################################################

rollback_summary() {

    echo

    echo "Rollback Items : ${#BACKUP_ITEMS[@]}"

    echo "Rollback Dir   : ${ROLLBACK_DIRECTORY}"

    echo

}

###############################################################################
# Public API
###############################################################################

export -f \
    register_backup \
    backup_file \
    backup_directory \
    restore_item \
    perform_rollback \
    cleanup_rollback \
    rollback_summary

###############################################################################
# Self Test
###############################################################################

rollback_self_test() {

    [[ -n "${ROLLBACK_DIRECTORY}" ]]

}