#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : deploy.sh
# Version     : 1.0.0
#
# Description :
# Main deployment entry point.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Root Directory
###############################################################################

DEPLOY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEPLOY_MODE="${DEPLOY_MODE:-PRODUCTION}"

###############################################################################
# Test Environment
###############################################################################

if [[ "${DEPLOY_MODE}" == "TEST" ]]
then

    TEST_ROOT="${DEPLOY_ROOT}/tests"

    SANDBOX_ROOT="${TEST_ROOT}/sandbox"

    export TEST_ROOT

    export SANDBOX_ROOT

    export PROJECT_SOURCE_ROOT="$(cd "${DEPLOY_ROOT}/../../TinQa_Weather_Sync_System" && pwd)"

fi

###############################################################################
# Core
###############################################################################

source "${DEPLOY_ROOT}/core/config.sh"
source "${DEPLOY_ROOT}/core/logger.sh"
source "${DEPLOY_ROOT}/core/banner.sh"

###############################################################################
# Configuration
###############################################################################

source "${DEPLOY_ROOT}/config/framework.conf"
source "${DEPLOY_ROOT}/config/files.conf"
source "${DEPLOY_ROOT}/config/packages.conf"
source "${DEPLOY_ROOT}/config/python_modules.conf"
source "${DEPLOY_ROOT}/config/services.conf"

###############################################################################
# Diagnostics
###############################################################################

source "${DEPLOY_ROOT}/diagnostics/system_info.sh"
source "${DEPLOY_ROOT}/diagnostics/service_logs.sh"
source "${DEPLOY_ROOT}/diagnostics/report.sh"

###############################################################################
# Validators
###############################################################################

source "${DEPLOY_ROOT}/validators/bluetooth.sh"

###############################################################################
# Utilities
###############################################################################

source "${DEPLOY_ROOT}/utils/project_scanner.sh"

###############################################################################
# Rollback
###############################################################################

source "${DEPLOY_ROOT}/rollback/rollback.sh"

###############################################################################
# Modules
###############################################################################

source "${DEPLOY_ROOT}/modules/01_cleanup.sh"
source "${DEPLOY_ROOT}/modules/02_transfer.sh"
source "${DEPLOY_ROOT}/modules/03_system_packages.sh"
source "${DEPLOY_ROOT}/modules/04_python_environment.sh"
source "${DEPLOY_ROOT}/modules/05_python_packages.sh"
source "${DEPLOY_ROOT}/modules/06_bluetooth.sh"
source "${DEPLOY_ROOT}/modules/07_system_validation.sh"
source "${DEPLOY_ROOT}/modules/08_systemd.sh"
source "${DEPLOY_ROOT}/modules/09_healthcheck.sh"
source "${DEPLOY_ROOT}/modules/10_finish.sh"

###############################################################################
# Deployment Information
###############################################################################

export DEPLOYMENT_START_TIME

DEPLOYMENT_START_TIME="$(date)"

###############################################################################
# Error Handler
###############################################################################

deployment_error() {

    local exit_code="$?"

    local line="$1"

    log_error "Deployment failed."

    log_error "Line : ${line}"

    log_error "Exit : ${exit_code}"

    collect_system_information || true

    collect_service_logs || true

    generate_report || true

    if [[ "${DEPLOY_MODE}" == "TEST" ]]
    then

        log_warning "Rollback skipped (TEST MODE)."

    else

        rollback || true

    fi

    exit "${exit_code}"

}

trap 'deployment_error ${LINENO}' ERR

###############################################################################
# Initialize
###############################################################################

initialize_framework() {

    initialize_configuration

    initialize_logger

    clear

    show_banner

    # section "TinQa Deployment Framework"

    if [[ "${DEPLOY_MODE}" == "TEST" ]]
    then
        source "${TEST_ROOT}/mock_commands.sh"

        log_warning "Running in TEST MODE"

        log_info "Sandbox : ${SANDBOX_ROOT}"

    else

        log_info "Running in PRODUCTION MODE"

    fi

}

###############################################################################
# Execute Modules
###############################################################################

execute_modules() {

    local modules=(
        run_cleanup
        run_transfer
        run_system_packages
        run_python_environment
        run_python_packages
        run_bluetooth
        run_system_validation
        run_systemd
        run_healthcheck
        run_finish
    )

    local total="${#modules[@]}"

    local current=0

    local module

    for module in "${modules[@]}"
    do
        ((++current))

        echo ">>> About to execute: ${module}"

        module_progress \
            "${current}" \
            "${total}" \
            "${module}"

        echo ">>> Calling ${module}"

        "${module}"

        echo ">>> Finished ${module}"
    done

}

###############################################################################
# Footer
###############################################################################

finish_framework() {

    deployment_finished

}

###############################################################################
# Main
###############################################################################

main() {

    initialize_framework

    execute_modules

    finish_framework

}

###############################################################################
# Execute
###############################################################################

main "$@"