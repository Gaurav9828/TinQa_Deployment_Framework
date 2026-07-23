#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# Functional Test Engine
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Counters
###############################################################################

declare -i FUNCTIONAL_PASS_COUNT=0
declare -i FUNCTIONAL_FAIL_COUNT=0

###############################################################################
# Result Storage
###############################################################################

declare -ag FUNCTIONAL_RESULTS=()

###############################################################################
# Pass
###############################################################################

functional_pass() {

    ((++FUNCTIONAL_PASS_COUNT))

    FUNCTIONAL_RESULTS+=(
        "PASS : $1"
    )

    log_success "$1"

}

###############################################################################
# Fail
###############################################################################

functional_fail() {

    ((++FUNCTIONAL_FAIL_COUNT))

    FUNCTIONAL_RESULTS+=(
        "FAIL : $1"
    )

    log_error "$1"

}

###############################################################################
# Test Python
###############################################################################

###############################################################################
# Test Python
###############################################################################

test_python() {

    log_info "Checking Python Runtime..."

    if remote_exec "${VENV_DIRECTORY}/bin/python" --version >/dev/null 2>&1
    then
        functional_pass "Python Runtime"
    else
        functional_fail "Python Runtime"
    fi

}

###############################################################################
# Test Virtual Environment
###############################################################################

test_virtual_environment() {

    log_info "Checking Virtual Environment..."

    if remote_exec test -f "${VENV_DIRECTORY}/bin/python"
    then
        functional_pass "Virtual Environment"
    else
        functional_fail "Virtual Environment"
    fi

}

###############################################################################
# Test Python Packages
###############################################################################

test_python_packages() {

    log_info "Checking Python Packages..."

    local module

    for module in "${PYTHON_IMPORT_MODULES[@]}"
    do

        if remote_exec \
            "${VENV_DIRECTORY}/bin/python" \
            -c "import ${module}" >/dev/null 2>&1
        then

            functional_pass "Python Module : ${module}"

        else

            functional_fail "Python Module : ${module}"

        fi

    done

}

###############################################################################
# Test Bluetooth
###############################################################################

test_bluetooth() {

    log_info "Checking Bluetooth..."

    if remote_exec bluetoothctl list >/dev/null 2>&1
    then
        functional_pass "Bluetooth Adapter"
    else
        functional_fail "Bluetooth Adapter"
    fi

}

###############################################################################
# Test Services
###############################################################################

test_services() {

    log_info "Checking Services..."

    local service

    for service in "${SYSTEMD_SERVICES[@]}"
    do

        if remote_exec systemctl is-active --quiet "${service}"
        then

            functional_pass "${service}"

        else

            functional_fail "${service}"

        fi

    done

}

###############################################################################
# Test Project Directory
###############################################################################

test_project_directory() {

    log_info "Checking Project Directory..."

    if target_exec test -d "${PROJECT_ROOT}"
    then
        functional_pass "Project Directory"
    else
        functional_fail "Project Directory"
    fi

}

###############################################################################
# Summary
###############################################################################

functional_summary() {

    echo
    echo "=============================================================="
    echo "Functional Test Summary"
    echo "=============================================================="

    local item

    for item in "${FUNCTIONAL_RESULTS[@]}"
    do
        echo "${item}"
    done

    echo
    echo "Passed : ${FUNCTIONAL_PASS_COUNT}"
    echo "Failed : ${FUNCTIONAL_FAIL_COUNT}"
    echo

}

###############################################################################
# Execute Functional Tests
###############################################################################

functional_tests_execute() {

    FUNCTIONAL_RESULTS=()
    FUNCTIONAL_PASS_COUNT=0
    FUNCTIONAL_FAIL_COUNT=0

    test_project_directory

    test_virtual_environment

    test_python

    test_python_packages

    test_bluetooth

    test_services

    functional_summary

    if (( FUNCTIONAL_FAIL_COUNT == 0 ))
    then
        inspect_set functional_tests yes
    else
        inspect_set functional_tests no
    fi

}

###############################################################################
# Export
###############################################################################

export -f functional_tests_execute