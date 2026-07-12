#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 04_python_environment.sh
# Version     : 1.0.0
#
# Description :
# Creates and validates Python virtual environment.
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
source "${DEPLOY_ROOT}/config/python_modules.conf"

###############################################################################
# Verify Python
###############################################################################

verify_python() {

    log_info "Checking Python installation..."

    command -v "${PYTHON_BINARY}" >/dev/null

    log_success "Python detected."

}

###############################################################################
# Create Virtual Environment
###############################################################################

create_virtual_environment() {

    log_info "Creating virtual environment..."

    rm -rf "${VENV_DIRECTORY}"

    "${PYTHON_BINARY}" \
        -m venv \
        "${VENV_DIRECTORY}"

    log_success "Virtual environment created."

}

###############################################################################
# Activate Environment
###############################################################################

activate_virtual_environment() {

    log_info "Activating virtual environment..."

    # shellcheck disable=SC1091
    source "${VENV_DIRECTORY}/bin/activate"

    log_success "Virtual environment activated."

}

###############################################################################
# Upgrade Pip
###############################################################################

upgrade_pip() {

    log_info "Upgrading pip..."

    python -m pip install \
        "${PIP_INSTALL_OPTIONS[@]}" \
        "${PIP_BOOTSTRAP_PACKAGES[@]}"

    log_success "Pip upgraded."

}

###############################################################################
# Verify Environment
###############################################################################

verify_virtual_environment() {

    log_info "Verifying virtual environment..."

    [[ -f "${VENV_DIRECTORY}/bin/python" ]]

    [[ -f "${VENV_DIRECTORY}/bin/pip" ]]

    log_success "Virtual environment verified."

}

###############################################################################
# Python Version
###############################################################################

show_python_version() {

    log_info "Python Version : $(python --version 2>&1)"

    log_info "Pip Version    : $(pip --version)"

}

###############################################################################
# Deactivate Environment
###############################################################################

deactivate_virtual_environment() {

    if declare -F deactivate >/dev/null
    then
        deactivate
    fi

    log_success "Virtual environment deactivated."

}

###############################################################################
# Main
###############################################################################

run_python_environment() {

    section "Module 04 - Python Environment"

    verify_python

    create_virtual_environment

    activate_virtual_environment

    upgrade_pip

    verify_virtual_environment

    show_python_version

    deactivate_virtual_environment

    log_success "Python environment completed."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_python_environment