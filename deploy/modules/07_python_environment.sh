#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 07_python_environment.sh
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

    if ! command -v "${PYTHON_BINARY}" >/dev/null
    then

        repair_execute \
            "Python" \
            repair_python

        command -v "${PYTHON_BINARY}" >/dev/null

    fi

    inspect_set python_ok yes

    log_success "Python detected."

}

###############################################################################
# Create Virtual Environment
###############################################################################

create_virtual_environment() {

    log_info "Preparing virtual environment..."

    if [[ -d "${VENV_DIRECTORY}" ]]
    then

        log_info "Virtual environment already exists."

        return 0

    fi

    if ! "${PYTHON_BINARY}" \
        -m venv \
        "${VENV_DIRECTORY}"
    then

        repair_execute \
            "Virtual Environment" \
            repair_virtual_environment

        "${PYTHON_BINARY}" \
            -m venv \
            "${VENV_DIRECTORY}"

    fi

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

    if [[ \
        -f "${VENV_DIRECTORY}/bin/python" \
        && \
        -f "${VENV_DIRECTORY}/bin/pip" \
    ]]
    then

        inspect_set venv_ok yes

        log_success "Virtual environment verified."

    else

        inspect_set venv_ok no

        return 1

    fi

}

###############################################################################
# Python Version
###############################################################################

show_python_version() {

    local python_version
    local pip_version

    python_version="$(python --version 2>&1)"
    pip_version="$(pip --version)"

    inspect_set python_version "${python_version}"
    inspect_set pip_version "${pip_version}"

    log_info "Python Version : ${python_version}"
    log_info "Pip Version    : ${pip_version}"

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

run_07_python_environment() {

    section "Module 07 - Python Environment"

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
    run_07_python_environment