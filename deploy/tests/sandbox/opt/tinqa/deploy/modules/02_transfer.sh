#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 02 - Project Transfer
###############################################################################

set -Eeuo pipefail

transfer_project() {

    step "Transfer Project"

    set_error "$E300" "Local project directory not found"

    run "Verifying Local Project" \
        assert_directory_exists \
        "${LOCAL_PROJECT_DIR}"

    run "Verifying requirements.txt" \
        assert_file_exists \
        "${LOCAL_PROJECT_DIR}/${REQUIREMENTS_FILE}"

    set_error "$E200" "Unable to connect to Raspberry Pi"

    run "Verifying SSH Connection" \
        check_ssh

    set_error "$E300" "Unable to prepare remote directory"

    run "Creating Remote Project Directory" \
        remote_exec_safe \
        "mkdir -p '${REMOTE_PROJECT_DIR}'"

    set_error "$E300" "Project transfer failed"

    run "Synchronizing Project Files" \
        rsync_project

    set_error "$E300" "Remote project verification failed"

    run "Verifying Remote Project Directory" \
        remote_directory_exists \
        "${REMOTE_PROJECT_DIR}"

    run "Verifying requirements.txt on Raspberry Pi" \
        remote_file_exists \
        "${REMOTE_PROJECT_DIR}/${REQUIREMENTS_FILE}"

    local LOCAL_FILES
    local REMOTE_FILES

    LOCAL_FILES=$(find "${LOCAL_PROJECT_DIR}" \
        -type f \
        ! -path "*/venv/*" \
        ! -path "*/__pycache__/*" \
        ! -path "*/.git/*" \
        ! -path "*/.pytest_cache/*" \
        ! -path "*/htmlcov/*" \
        | wc -l)

    REMOTE_FILES=$(remote_exec \
        "find '${REMOTE_PROJECT_DIR}' \
        -type f \
        ! -path '*/venv/*' \
        ! -path '*/__pycache__/*' \
        | wc -l")

    log_info "Local Files  : ${LOCAL_FILES}"
    log_info "Remote Files : ${REMOTE_FILES}"

    if [[ "${LOCAL_FILES}" != "${REMOTE_FILES}" ]]; then

        set_error "$E300" "Transferred file count does not match"

        return 1

    fi

    log_success "Project Transfer Completed"

}