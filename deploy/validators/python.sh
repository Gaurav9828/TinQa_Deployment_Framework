#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : python.sh
# Version     : 1.0.0
#
# Description :
# Python runtime and virtual environment validation utilities.
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

###############################################################################
# Validate Python Binary
###############################################################################

validate_python() {

    log_info "Checking Python installation..."

    if command -v "${PYTHON_BINARY}" >/dev/null 2>&1
    then
        log_success "Python installation verified."
        return 0
    fi

    log_error "Python not found."

    return 1

}

###############################################################################
# Validate Pip
###############################################################################

validate_pip() {

    log_info "Checking pip..."

    if command -v "${PIP_BINARY}" >/dev/null 2>&1
    then
        log_success "Pip installation verified."
        return 0
    fi

    log_error "Pip not found."

    return 1

}

###############################################################################
# Validate Virtual Environment
###############################################################################

validate_virtual_environment() {

    log_info "Checking virtual environment..."

    if [[ -d "${VENV_DIRECTORY}" ]]
    then
        log_success "Virtual environment found."
        return 0
    fi

    log_error "Virtual environment missing."

    return 1

}

###############################################################################
# Validate Python Executable
###############################################################################

validate_venv_python() {

    log_info "Checking virtual environment Python..."

    if [[ -x "${VENV_DIRECTORY}/bin/python" ]]
    then
        log_success "Virtual environment Python verified."
        return 0
    fi

    log_error "Virtual environment Python missing."

    return 1

}

###############################################################################
# Validate Pip Executable
###############################################################################

validate_venv_pip() {

    log_info "Checking virtual environment pip..."

    if [[ -x "${VENV_DIRECTORY}/bin/pip" ]]
    then
        log_success "Virtual environment pip verified."
        return 0
    fi

    log_error "Virtual environment pip missing."

    return 1

}

###############################################################################
# Validate Installed Package
###############################################################################

validate_python_module() {
    local package="$1"
    local module="$package"

    # Map PyPI package names to their actual Python import names
    case "${package}" in
        PyYAML|pyyaml)
            module="yaml"
            ;;
        opencv-python|opencv-python-headless|cv2)
            module="cv2"
            ;;
        pyserial)
            module="serial"
            ;;
    esac

    # Test the import
    if [[ "${DEPLOY_MODE:-PRODUCTION}" == "TEST" ]]; then
        # In TEST mode, skip execution or use mock
        return 0
    else
        "${VENV_PYTHON:-python3}" -c "import ${module}" >/dev/null 2>&1
    fi
}

validate_package() {

    local package="$1"

    if validate_python_module "${package}"
    then
        log_success "Package installed : ${package}"
        return 0
    fi

    log_error "Package missing : ${package}"

    return 1

}

###############################################################################
# Validate All Packages
###############################################################################

validate_packages() {

    local failed=0

    local package

    for package in "${PYTHON_REQUIRED_PACKAGES[@]}"
    do

        validate_package "${package}" || failed=1

    done

    return "${failed}"

}

###############################################################################
# Validate Dependency Integrity
###############################################################################

validate_dependency_integrity() {

    log_info "Checking Python dependency integrity..."

    if python -m pip check >/dev/null
    then
        log_success "Dependency integrity verified."
        return 0
    fi

    log_error "Dependency conflicts detected."

    return 1

}

###############################################################################
# Validate Python Runtime
###############################################################################

validate_python_runtime() {

    validate_python
    validate_pip
    validate_virtual_environment
    validate_venv_python
    validate_venv_pip
    validate_dependency_integrity

}

###############################################################################
# Public API
###############################################################################

export -f \
    validate_python \
    validate_pip \
    validate_virtual_environment \
    validate_venv_python \
    validate_venv_pip \
    validate_package \
    validate_packages \
    validate_dependency_integrity \
    validate_python_runtime