#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 05_transfer.sh
# Version     : 1.0.0
#
# Description :
# Transfers application files to deployment directory.
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
# Validate Source
###############################################################################

validate_source_directory() {

    log_info "Validating project source..."
    log_info "Source : ${PROJECT_SOURCE_ROOT}"

    if [[ ! -d "${PROJECT_SOURCE_ROOT}" ]]
    then
        inspect_set source_ok no

        log_error "Source directory not found."

        return 1
    fi
    inspect_set source_ok yes
    log_success "Source directory verified."
}

###############################################################################
# Create Deployment Directory
###############################################################################

create_deployment_directory() {

    log_info "Preparing deployment directory..."

    mkdir -p "${PROJECT_DEPLOY_ROOT}"

    [[ -d "${PROJECT_DEPLOY_ROOT}" ]]

    log_success "Deployment directory ready."

}

###############################################################################
# Copy Project Files
###############################################################################

copy_project_files() {

    log_info "Copying project files..."

    local rsync_excludes=()

    local pattern

    for pattern in "${EXCLUDED_PATTERNS[@]}"
    do
        rsync_excludes+=(
            --exclude="${pattern}"
        )
    done

    if ! rsync \
        -a \
        --delete \
        "${rsync_excludes[@]}" \
        "${PROJECT_SOURCE_ROOT}/" \
        "${PROJECT_DEPLOY_ROOT}/"
    then

        repair_execute \
            "Network" \
            repair_network

        rsync \
            -a \
            --delete \
            "${rsync_excludes[@]}" \
            "${PROJECT_SOURCE_ROOT}/" \
            "${PROJECT_DEPLOY_ROOT}/"

    fi

    log_success "Project files copied."

}

###############################################################################
# Verify Transfer
###############################################################################

verify_transfer() {

    log_info "Verifying deployment..."

    if compare_project_structure \
        "${PROJECT_SOURCE_ROOT}" \
        "${PROJECT_DEPLOY_ROOT}"
    then

        inspect_set project_uploaded yes

        log_success "Deployment verification passed."

    else

        inspect_set project_uploaded no

        return 1

    fi

}

###############################################################################
# File Statistics
###############################################################################

show_transfer_statistics() {

    local count

    count=$(find "${PROJECT_DEPLOY_ROOT}" -type f | wc -l)
    inspect_set deployed_files "${count}"
    log_info "Files deployed : ${count}"

}

###############################################################################
# Main
###############################################################################

run_05_transfer() {

    section "Module 05 - File Transfer"

    validate_source_directory

    create_deployment_directory

    copy_project_files

    verify_transfer

    show_transfer_statistics

    log_success "File transfer completed."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_05_transfer