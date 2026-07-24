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

    FAKE_PI_ROOT="${SANDBOX_ROOT}"

    export TEST_ROOT
    export SANDBOX_ROOT
    export FAKE_PI_ROOT

    export PROJECT_SOURCE_ROOT="$(cd "${DEPLOY_ROOT}/../../TinQa_Weather_Sync_System" && pwd)"

fi

if [[ "${DEPLOY_MODE}" == "TEST" ]]
then
    source "${TEST_ROOT}/mock_commands.sh"
    echo "TEST_ROOT=$TEST_ROOT"
    echo "Loading: ${TEST_ROOT}/mock_commands.sh"
    ls -l "${TEST_ROOT}/mock_commands.sh"
fi

###############################################################################
# Core
###############################################################################

source "${DEPLOY_ROOT}/core/config.sh"
source "${DEPLOY_ROOT}/core/logger.sh"
source "${DEPLOY_ROOT}/core/banner.sh"
source "${DEPLOY_ROOT}/core/execution/module_runner.sh"
source "${DEPLOY_ROOT}/core/execution/target_exec.sh"
source "${DEPLOY_ROOT}/core/inspect.sh"
source "${DEPLOY_ROOT}/core/planner/action_plan.sh"
source "${DEPLOY_ROOT}/core/registry/modules.sh"
source "${DEPLOY_ROOT}/core/healing/repair.sh"


###############################################################################
# Configuration
###############################################################################

source "${DEPLOY_ROOT}/config/framework.conf"
source "${DEPLOY_ROOT}/config/deployment.conf"
source "${DEPLOY_ROOT}/config/files.conf"
source "${DEPLOY_ROOT}/config/packages.conf"
source "${DEPLOY_ROOT}/config/python_modules.conf"
source "${DEPLOY_ROOT}/config/services.conf"

###############################################################################
# TEST MODE PATH OVERRIDES
###############################################################################

if [[ "${DEPLOY_MODE}" == "TEST" ]]
then

    DEPLOYMENT_LOG_DIRECTORY="${SANDBOX_ROOT}/var/log/tinqa-deploy"

    DEPLOYMENT_DIAGNOSTICS_DIRECTORY="${DEPLOYMENT_LOG_DIRECTORY}/diagnostics"

    DEPLOYMENT_REPORT_DIRECTORY="${DEPLOYMENT_LOG_DIRECTORY}/reports"

    DEPLOYMENT_ROLLBACK_DIRECTORY="${DEPLOYMENT_LOG_DIRECTORY}/rollback"

    export DEPLOYMENT_LOG_DIRECTORY
    export DEPLOYMENT_DIAGNOSTICS_DIRECTORY
    export DEPLOYMENT_REPORT_DIRECTORY
    export DEPLOYMENT_ROLLBACK_DIRECTORY

fi

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
export DEPLOYMENT_START_EPOCH
DEPLOYMENT_START_EPOCH="$(date +%s)"

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
# Framework Validation
###############################################################################

validate_linux() {

    if [[ "$(uname -s)" != "Linux" ]]
    then
        log_error "TinQa deployment only supports Linux."
        exit 1
    fi

}

validate_raspberry_pi() {

    [[ "${DEPLOY_MODE}" == "TEST" ]] && return 0

    if ! grep -qi raspberry /proc/device-tree/model 2>/dev/null
    then
        log_error "This deployment only supports Raspberry Pi."

        exit 1
    fi

}

validate_sudo() {

    [[ "${DEPLOY_MODE}" == "TEST" ]] && return 0

    log_info "Validating sudo access..."

    sudo -v

    log_success "Sudo access verified."

}

validate_internet() {

    [[ "${DEPLOY_MODE}" == "TEST" ]] && return 0

    log_info "Checking internet connectivity..."

    if ping -c1 8.8.8.8 >/dev/null 2>&1
    then
        log_success "Internet connection available."
    else
        log_error "Internet connection unavailable."

        exit 1
    fi

}

validate_required_commands() {

    [[ "${DEPLOY_MODE}" == "TEST" ]] && return 0

    local command

    local required_commands=(

        git
        rsync
        python3
        systemctl
        bluetoothctl
        apt-get

    )

    for command in "${required_commands[@]}"
    do

        if command -v "${command}" >/dev/null 2>&1
        then
            log_success "Found : ${command}"
        else
            log_error "Missing : ${command}"

            exit 1
        fi

    done

}

###############################################################################
# Initialize
###############################################################################

initialize_framework() {

    initialize_configuration

    initialize_logger

    clear

    show_banner

    validate_linux

    validate_raspberry_pi

    validate_sudo

    validate_internet

    validate_required_commands

    # section "TinQa Deployment Framework"

    if [[ "${DEPLOY_MODE}" == "TEST" ]]
    then

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

        echo "DEBUG: module=${module}"

        declare -F "${module}" || echo "Function ${module} NOT FOUND"

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