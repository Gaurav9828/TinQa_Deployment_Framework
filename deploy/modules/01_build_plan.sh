#!/usr/bin/env bash
###############################################################################
#
# Module 01 - Build Plan
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Helper
###############################################################################

inspect_remote() {

    local key="$1"
    shift

    if remote_exec "$@" >/dev/null 2>&1
    then
        inspect_set "${key}" yes
    else
        inspect_set "${key}" no
    fi

}

###############################################################################
# Build Plan
###############################################################################

run_01_build_plan() {

    section "Module 01 - Build Plan"

    inspect_clear
    plan_clear

    ###########################################################################
    # TEST MODE
    ###########################################################################

    if [[ "${DEPLOY_MODE}" == "TEST" ]]
    then

        inspect_set python_installed yes
        inspect_set bluetooth_ok yes
        inspect_set internet yes
        inspect_set venv_exists no

        plan_add run_02_cleanup
        plan_add run_03_transfer
        plan_add run_04_system_packages
        plan_add run_05_python_environment
        plan_add run_06_python_packages
        plan_add run_07_bluetooth
        plan_add run_08_system_validation
        plan_add run_09_systemd
        plan_add run_10_healthcheck
        plan_add run_11_finish

        plan_print

        return 0

    fi

    ###########################################################################
    # Inspect Remote Machine
    ###########################################################################

    inspect_remote python_installed python3 --version
    inspect_remote bluetooth_ok bluetoothctl list
    inspect_remote internet ping -c1 8.8.8.8
    inspect_remote venv_exists test -d /opt/tinqa/venv

    ###########################################################################
    # Build Deployment Plan
    ###########################################################################

    inspect_no python_installed && \
        plan_add run_04_system_packages \
        "Python runtime missing"

    inspect_no venv_exists && \
        plan_add run_05_python_environment \
        "Python virtual environment missing"

    plan_add run_06_python_packages

    inspect_no bluetooth_ok && \
        plan_add run_07_bluetooth \
        "Bluetooth adapter unavailable"

    plan_add run_08_system_validation \
        "Final verification"

    plan_add run_09_systemd
    plan_add run_10_healthcheck
    plan_add run_11_finish

    ###########################################################################
    # Summary
    ###########################################################################

    inspect_dump
    plan_print

}

export -f run_01_build_plan