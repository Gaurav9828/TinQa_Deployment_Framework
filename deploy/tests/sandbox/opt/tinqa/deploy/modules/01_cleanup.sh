#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 01 - Cleanup
###############################################################################

set -Eeuo pipefail

cleanup_pi() {

    step "Cleaning Previous Installation"

    set_error "$E200" "Unable to connect to Raspberry Pi"

    run "Checking SSH Connectivity" \
        check_ssh

    set_error "$E202" "Failed while cleaning Raspberry Pi"

    run "Stopping TinQa Service" \
        remote_exec_safe \
        "sudo systemctl stop ${SERVICE_NAME} 2>/dev/null || true"

    run "Disabling TinQa Service" \
        remote_exec_safe \
        "sudo systemctl disable ${SERVICE_NAME} 2>/dev/null || true"

    run "Removing Systemd Service" \
        remote_exec_safe \
        "sudo rm -f /etc/systemd/system/${SERVICE_NAME}"

    run "Reloading Systemd" \
        remote_exec_safe \
        "sudo systemctl daemon-reload"

    run "Removing Previous Project" \
        remote_exec_safe \
        "rm -rf ${REMOTE_PROJECT_DIR}"

    run "Cleaning Bluetooth Cache" \
        remote_exec_safe \
        "sudo rm -rf /var/lib/bluetooth/*/cache/* 2>/dev/null || true"

    run "Stopping Bluetooth Service" \
        remote_exec_safe \
        "sudo systemctl stop bluetooth 2>/dev/null || true"

    run "Removing Previous Virtual Environment" \
        remote_exec_safe \
        "rm -rf ${REMOTE_PROJECT_DIR}/${VENV_NAME}"

    log_success "Cleanup Completed"

}