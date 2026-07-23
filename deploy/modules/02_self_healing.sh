#!/usr/bin/env bash
###############################################################################
#
# Module 02 - Self Healing
#
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${DEPLOY_ROOT}/core/healing/repair.sh"

###############################################################################

run_02_self_healing() {

    section "Module 02 - Self Healing"

    ####################################################
    # Internet
    ####################################################

    inspect_no internet && \
        repair_network

    ####################################################
    # Python
    ####################################################

    inspect_no python_installed && \
        repair_python

    ####################################################
    # Virtual Environment
    ####################################################

    inspect_no venv_exists && \
        repair_virtual_environment

    ####################################################
    # Bluetooth
    ####################################################

    inspect_no bluetooth_ok && \
        repair_bluetooth

    log_success "Self healing completed."

}

export -f run_02_self_healing