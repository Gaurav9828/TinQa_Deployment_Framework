#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 05_python_packages.sh
# Version     : 1.0.0
#
# Description :
# Installs and validates Python packages.
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
# Activate Virtual Environment
###############################################################################

activate_virtual_environment() {

    log_info "Activating virtual environment..."

    # shellcheck disable=SC1091
    source "${VENV_DIRECTORY}/bin/activate"

    log_success "Virtual environment activated."

}

###############################################################################
# Install Requirements
###############################################################################

install_requirements() {

    if [[ -f "${REQUIREMENTS_FILE}" ]]
    then

        log_info "Installing packages from requirements.txt..."

        pip install \
            "${PIP_INSTALL_OPTIONS[@]}" \
            -r "${REQUIREMENTS_FILE}"

    else

        log_warning "requirements.txt not found."

        log_info "Installing configured Python packages..."

        pip install \
            "${PIP_INSTALL_OPTIONS[@]}" \
            "${PYTHON_REQUIRED_PACKAGES[@]}"

    fi

    log_success "Python packages installed."

}

###############################################################################
# Verify Packages
###############################################################################

verify_python_packages() {

    log_info "Verifying installed packages..."

    local package

    local failed=0

    for package in "${PYTHON_REQUIRED_PACKAGES[@]}"
    do

        if pip show "${package}" >/dev/null 2>&1
        then

            log_success "Verified : ${package}"

        else

            log_error "Missing : ${package}"

            failed=1

        fi

    done

    return "${failed}"

}

###############################################################################
# Dependency Check
###############################################################################

check_dependency_health() {

    log_info "Checking dependency integrity..."

    python -m pip check

    log_success "Dependency check passed."

}

###############################################################################
# Freeze Installed Packages
###############################################################################

freeze_packages() {

    log_info "Saving installed package list..."

    pip freeze \
        > "${APPLICATION_LOG_DIRECTORY}/installed_packages.txt"

    log_success "Package list exported."

}

###############################################################################
# Package Summary
###############################################################################

package_summary() {

    local total

    total=$(pip list --format=freeze | wc -l)

    log_info "Installed Python packages : ${total}"

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

run_python_packages() {

    section "Module 05 - Python Packages"

    activate_virtual_environment

    install_requirements

    verify_python_packages

    check_dependency_health

    freeze_packages

    package_summary

    deactivate_virtual_environment

    log_success "Python package installation completed."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_python_packages