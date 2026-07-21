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
source "${DEPLOY_ROOT}/core/execution/module_runner.sh"
source "${DEPLOY_ROOT}/core/inspect.sh"
source "${DEPLOY_ROOT}/core/planner/action_plan.sh"
source "${DEPLOY_ROOT}/core/registry/modules.sh"

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
# Load Modules
###############################################################################

while IFS= read -r module
do
    source "${module}"

    module_name="$(basename "${module}" .sh)"

    register_module "${module_name}"

done < <(

    find "${DEPLOY_ROOT}/modules" \
        -maxdepth 1 \
        -name "*.sh" \
        | sort

)

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

    local total="${#ACTIONS[@]}"
    local current=0
    local module

    if [[ "${total}" -eq 0 ]]
    then
        log_warning "No deployment actions planned."

        return 0
    fi

    echo
    echo "=============================================================="
    echo "Executing Deployment Plan"
    echo "=============================================================="
    echo

    for module in "${ACTIONS[@]}"
    do
        ((++current))

        module_progress \
            "${current}" \
            "${total}" \
            "${module#run_}"

        log_info "Executing ${module}"

        run_module "${module}"

        log_success "Completed ${module}"

        echo

    done

    echo "=============================================================="
    log_success "Deployment execution completed."
    echo "=============================================================="
    echo

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

    #
    # Framework Phase
    #
    run_00_preflight
    run_01_build_plan

    #
    # Deployment Phase
    #
    execute_modules

    finish_framework

}

###############################################################################
# Execute
###############################################################################

main "$@"