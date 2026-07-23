#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 04 - Python Environment
###############################################################################

set -Eeuo pipefail

create_python_environment() {

    module_begin "Creating Python Environment"

    ###########################################################################
    # Verify Python
    ###########################################################################

    set_error "$E500" "Python3 is not installed on Raspberry Pi"

    run "Checking Python Installation" \
        remote_command_exists \
        "${PYTHON_EXECUTABLE}"

    ###########################################################################
    # Remove Existing VENV
    ###########################################################################

    run "Removing Existing Virtual Environment" \
        remote_exec_safe \
        "rm -rf '${REMOTE_VENV}'"

    ###########################################################################
    # Create VENV
    ###########################################################################

    set_error "$E500" "Unable to create Python Virtual Environment"

    run "Creating Virtual Environment" \
        remote_exec_safe \
        "
        cd '${REMOTE_PROJECT_DIR}' &&
        ${PYTHON_EXECUTABLE} -m venv '${VENV_NAME}'
        "

    ###########################################################################
    # Verify VENV
    ###########################################################################

    run "Verifying Virtual Environment" \
        remote_directory_exists \
        "${REMOTE_VENV}"

    ###########################################################################
    # Verify Python Executable
    ###########################################################################

    run "Checking Virtual Environment Python" \
        remote_file_exists \
        "${REMOTE_VENV}/bin/python"

    ###########################################################################
    # Verify Pip
    ###########################################################################

    run "Checking Pip" \
        remote_file_exists \
        "${REMOTE_VENV}/bin/pip"

    ###########################################################################
    # Upgrade Pip
    ###########################################################################

    set_error "$E501" "Unable to upgrade pip"

    run "Upgrading pip" \
        remote_exec_safe \
        "
        '${REMOTE_VENV}/bin/python' \
        -m pip install \
        --upgrade \
        pip \
        setuptools \
        wheel
        "

    ###########################################################################
    # Display Versions
    ###########################################################################

    log_info "Python Version"

    remote_exec \
        "'${REMOTE_VENV}/bin/python' --version"

    log_info "Pip Version"

    remote_exec \
        "'${REMOTE_VENV}/bin/pip' --version"

    ###########################################################################
    # Verify Pip Works
    ###########################################################################

    run "Testing pip" \
        remote_exec_safe \
        "'${REMOTE_VENV}/bin/pip' list >/dev/null"

    ###########################################################################
    # Success
    ###########################################################################

    module_end

}