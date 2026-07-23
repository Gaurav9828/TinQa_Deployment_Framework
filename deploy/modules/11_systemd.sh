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

    if [[ -f "${SERVICE_TEMPLATE}" ]]
    then

        inspect_set systemd_template_ok yes

        log_success "Template found."

    else

        inspect_set systemd_template_ok no

        log_error "Missing template : ${SERVICE_TEMPLATE}"

        return 1

    fi

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

    if ! sudo cp \
        "${TEMP_SERVICE_FILE}" \
        "${SYSTEMD_SERVICE_FILE}"
    then

        repair_execute \
            "Systemd" \
            repair_systemd

        sudo cp \
            "${TEMP_SERVICE_FILE}" \
            "${SYSTEMD_SERVICE_FILE}"

    fi

    sudo chmod 644 "${SYSTEMD_SERVICE_FILE}"

    log_success "Service installed."

}

###############################################################################
# Reload Systemd
###############################################################################

reload_systemd() {

    log_info "Reloading systemd..."

    if ! sudo systemctl daemon-reload
    then

        repair_execute \
            "Systemd" \
            repair_systemd

        sudo systemctl daemon-reload

    fi

    log_success "Systemd reloaded."

}

###############################################################################
# Enable Service
###############################################################################

enable_service() {

    log_info "Enabling TinQa service..."

    if ! sudo systemctl enable "${TINQA_SERVICE_NAME}"
    then

        repair_execute \
            "Systemd" \
            repair_systemd

        sudo systemctl enable "${TINQA_SERVICE_NAME}"

    fi

    log_success "Service enabled."

}

###############################################################################
# Start Service
###############################################################################

start_service() {

    log_info "Starting TinQa service..."

    if ! sudo systemctl restart "${TINQA_SERVICE_NAME}"
    then

        repair_execute \
            "Systemd" \
            repair_systemd

        sudo systemctl restart "${TINQA_SERVICE_NAME}"

    fi

    log_success "Service started."

}

###############################################################################
# Verify Installation
###############################################################################

verify_service() {

    log_info "Verifying installation..."

    if systemctl is-active --quiet "${TINQA_SERVICE_NAME}"
    then

        inspect_set systemd_ok yes

        log_success "Systemd installation verified."

    else

        inspect_set systemd_ok no

        log_error "TinQa service is not running."

        return 1

    fi

}

###############################################################################
# Main
###############################################################################

run_11_systemd() {

    section "Module 11 - Systemd"

    validate_template

    generate_service_file

    install_service

    reload_systemd

    enable_service

    start_service

    verify_service

    systemctl status \
        "${TINQA_SERVICE_NAME}" \
        --no-pager \
        > "${APPLICATION_LOG_DIRECTORY}/systemd_status.log" \
        2>&1 || true

    log_success "Systemd configuration completed."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_11_systemd