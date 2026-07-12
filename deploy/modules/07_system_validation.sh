#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 07_system_validation.sh
# Version     : 1.0.0
#
# Description :
# Validates complete deployment before systemd installation.
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
source "${DEPLOY_ROOT}/config/framework.conf"
source "${DEPLOY_ROOT}/validators/bluetooth.sh"

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
# Validate Project Structure
###############################################################################

validate_project_structure() {

    log_info "Validating project structure..."

    local failed=0

    local paths=(

        "${PROJECT_ROOT}"
        "${VENV_DIRECTORY}"
        "${REQUIREMENTS_FILE}"

    )

    local item

    for item in "${paths[@]}"
    do

        if [[ -e "${item}" ]]
        then

            log_success "Found : ${item}"

        else

            log_error "Missing : ${item}"

            failed=1

        fi

    done

    ###########################################################################
    # Validate copied project structure
    ###########################################################################

    compare_project_structure \
        "${PROJECT_SOURCE_ROOT}" \
        "${PROJECT_ROOT}" || failed=1

    return "${failed}"

}

###############################################################################
# Validate Python
###############################################################################

validate_python_runtime() {

    log_info "Validating Python runtime..."

    python --version >/dev/null

    pip --version >/dev/null

    log_success "Python runtime validated."

}

###############################################################################
# Validate Dependencies
###############################################################################

validate_python_dependencies() {

    log_info "Validating Python dependencies..."

    python -m pip check

    log_success "Dependency validation completed."

}

###############################################################################
# Validate Application Entry
###############################################################################

validate_application_entry() {

    log_info "Checking application entry point..."

    local entry_file="${PROJECT_ROOT}/${APPLICATION_ENTRY_FILE}"

    if [[ -f "${entry_file}" ]]
    then
        log_success "Application entry point found."
        return 0
    fi

    log_error "Missing : ${entry_file}"
    return 1
}

###############################################################################
# Import Test
###############################################################################

validate_application_import() {

    log_info "Testing application import..."

    cd "${PROJECT_ROOT}"

    python -c "import importlib; importlib.import_module('${APPLICATION_ENTRY_MODULE}')"
    
    log_success "Application import successful."

}

###############################################################################
# Validate Bluetooth
###############################################################################

validate_bluetooth_runtime() {

    log_info "Validating Bluetooth subsystem..."

    validate_bluetooth

}

###############################################################################
# Deactivate Environment
###############################################################################

deactivate_virtual_environment() {

    if declare -F deactivate >/dev/null
    then
        deactivate
    fi

}

###############################################################################
# Main
###############################################################################

run_system_validation() {

    section "Module 07 - System Validation"

    activate_virtual_environment

    validate_project_structure

    validate_python_runtime

    validate_python_dependencies

    validate_application_entry

    validate_application_import

    validate_bluetooth_runtime

    deactivate_virtual_environment

    log_success "System validation completed."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_system_validation