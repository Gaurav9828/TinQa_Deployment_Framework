#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 08_python_packages.sh
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

        if ! pip install \
            "${PIP_INSTALL_OPTIONS[@]}" \
            -r "${REQUIREMENTS_FILE}"
        then

            repair_execute \
                "Python" \
                repair_python

            pip install \
                "${PIP_INSTALL_OPTIONS[@]}" \
                -r "${REQUIREMENTS_FILE}"

        fi

    else

        log_warning "requirements.txt not found."

        log_info "Installing configured Python packages..."

        if ! pip install \
            "${PIP_INSTALL_OPTIONS[@]}" \
            "${PYTHON_REQUIRED_PACKAGES[@]}"
        then

            repair_execute \
                "Python" \
                repair_python

            pip install \
                "${PIP_INSTALL_OPTIONS[@]}" \
                "${PYTHON_REQUIRED_PACKAGES[@]}"

        fi

    fi

    log_success "Python packages installed."

}

###############################################################################
# Verify Packages
###############################################################################

validate_python_module() {
    # Guard for TEST mode
    if [[ "${DEPLOY_MODE:-PRODUCTION}" == "TEST" ]]; then
        return 0
    fi

    local package="$1"
    local module="$package"

    case "$package" in
        PyYAML) module="yaml" ;;
        opencv-python) module="cv2" ;;
        pyserial) module="serial" ;;
    esac

    python -c "import ${module}" >/dev/null 2>&1
}

verify_python_packages() {

    log_info "Verifying installed packages..."

    local package

    local failed=0

    for package in "${PYTHON_REQUIRED_PACKAGES[@]}"
    do

        if validate_python_module "${package}"
        then

            log_success "Verified : ${package}"

        else

            log_error "Missing : ${package}"

            failed=1

        fi

    done

    if (( failed == 0 ))
    then

        inspect_set python_packages_ok yes

    else

        inspect_set python_packages_ok no

    fi

    return "${failed}"

}

###############################################################################
# Dependency Check
###############################################################################

check_dependency_health() {

    log_info "Checking dependency integrity..."

    if python -m pip check
    then

        inspect_set dependency_health yes

        log_success "Dependency check passed."

    else

        inspect_set dependency_health no

        return 1

    fi

}

###############################################################################
# Freeze Installed Packages
###############################################################################

freeze_packages() {

    log_info "Saving installed package list..."
    mkdir -p "${APPLICATION_LOG_DIRECTORY}"
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

    inspect_set python_package_count "${total}"

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

run_08_python_packages() {

    section "Module 08 - Python Packages"

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
    run_08_python_packages