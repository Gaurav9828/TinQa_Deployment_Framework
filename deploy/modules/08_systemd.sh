#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 08_systemd.sh
# Version     : 1.0.0
#
# Description :
# Creates, installs and enables the TinQa systemd service.
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
source "${DEPLOY_ROOT}/config/services.conf"

###############################################################################
# Template
###############################################################################

SERVICE_TEMPLATE="${DEPLOY_ROOT}/templates/tinqa.service.template"

TEMP_SERVICE_FILE="${TEMP_DIRECTORY}/tinqa.service"

###############################################################################
# Validate Template
###############################################################################

validate_template() {

    log_info "Checking systemd template..."

    [[ -f "${SERVICE_TEMPLATE}" ]]

    log_success "Template found."

}

###############################################################################
# Generate Service
###############################################################################

generate_service_file() {

    log_info "Generating systemd service..."

    mkdir -p "${TEMP_DIRECTORY}"

    sed \
        -e "s|{{PROJECT_USER}}|${PROJECT_USER}|g" \
        -e "s|{{PROJECT_GROUP}}|${PROJECT_GROUP}|g" \
        -e "s|{{PROJECT_ROOT}}|${PROJECT_ROOT}|g" \
        -e "s|{{PYTHON_EXECUTABLE}}|${VENV_DIRECTORY}/bin/python|g" \
        -e "s|{{PYTHONPATH}}|${PROJECT_ROOT}|g" \
        "${SERVICE_TEMPLATE}" \
        > "${TEMP_SERVICE_FILE}"

    log_success "Service generated."
}

###############################################################################
# Install Service
###############################################################################

install_service() {

    log_info "Installing systemd service..."

    sudo cp \
        "${TEMP_SERVICE_FILE}" \
        "${SYSTEMD_SERVICE_FILE}"

    sudo chmod 644 "${SYSTEMD_SERVICE_FILE}"

    log_success "Service installed."

}

###############################################################################
# Reload Systemd
###############################################################################

reload_systemd() {

    log_info "Reloading systemd..."

    sudo systemctl daemon-reload

    log_success "Systemd reloaded."

}

###############################################################################
# Enable Service
###############################################################################

enable_service() {

    log_info "Enabling TinQa service..."

    sudo systemctl enable "${TINQA_SERVICE_NAME}"

    log_success "Service enabled."

}

###############################################################################
# Start Service
###############################################################################

start_service() {

    log_info "Starting TinQa service..."

    sudo systemctl restart "${TINQA_SERVICE_NAME}"

    log_success "Service started."

}

###############################################################################
# Verify Installation
###############################################################################

verify_service() {

    log_info "Verifying installation..."

    systemctl status \
        "${TINQA_SERVICE_NAME}" \
        --no-pager >/dev/null

    log_success "Systemd installation verified."

}

###############################################################################
# Main
###############################################################################

run_systemd() {

    section "Module 08 - Systemd"

    validate_template

    generate_service_file

    install_service

    reload_systemd

    enable_service

    start_service

    verify_service

    log_success "Systemd configuration completed."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_systemd