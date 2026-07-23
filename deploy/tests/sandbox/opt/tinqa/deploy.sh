#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Version : 1.0.0
# Author  : TinQa
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Load Configuration
# ---------------------------------------------------------------------------

source "$SCRIPT_DIR/deploy/config/config.sh"

# ---------------------------------------------------------------------------
# Load Core
# ---------------------------------------------------------------------------

source "$SCRIPT_DIR/deploy/core/colors.sh"
source "$SCRIPT_DIR/deploy/core/errors.sh"
source "$SCRIPT_DIR/deploy/core/logger.sh"
source "$SCRIPT_DIR/deploy/core/utils.sh"
source "$SCRIPT_DIR/deploy/core/banner.sh"

# ---------------------------------------------------------------------------
# Load Modules
# ---------------------------------------------------------------------------

source "$SCRIPT_DIR/deploy/modules/01_cleanup.sh"
source "$SCRIPT_DIR/deploy/modules/02_transfer.sh"
source "$SCRIPT_DIR/deploy/modules/03_system_packages.sh"
source "$SCRIPT_DIR/deploy/modules/04_python_environment.sh"
source "$SCRIPT_DIR/deploy/modules/05_python_packages.sh"
source "$SCRIPT_DIR/deploy/modules/06_bluetooth.sh"
source "$SCRIPT_DIR/deploy/modules/07_system_validation.sh"
source "$SCRIPT_DIR/deploy/modules/08_systemd.sh"
source "$SCRIPT_DIR/deploy/modules/09_healthcheck.sh"
source "$SCRIPT_DIR/deploy/modules/10_finish.sh"

# ---------------------------------------------------------------------------
# Load Validators
# ---------------------------------------------------------------------------

source "$SCRIPT_DIR/deploy/validators/system.sh"
source "$SCRIPT_DIR/deploy/validators/python.sh"
source "$SCRIPT_DIR/deploy/validators/network.sh"
source "$SCRIPT_DIR/deploy/validators/bluetooth.sh"
source "$SCRIPT_DIR/deploy/validators/runtime.sh"

# ---------------------------------------------------------------------------
# Load Diagnostics
# ---------------------------------------------------------------------------

source "$SCRIPT_DIR/deploy/diagnostics/system_info.sh"
source "$SCRIPT_DIR/deploy/diagnostics/service_logs.sh"
source "$SCRIPT_DIR/deploy/diagnostics/report.sh"

# ---------------------------------------------------------------------------
# Load Rollback
# ---------------------------------------------------------------------------

source "$SCRIPT_DIR/deploy/rollback/rollback.sh"

# ---------------------------------------------------------------------------
# Error Handling
# ---------------------------------------------------------------------------

trap 'handle_error $LINENO "$BASH_COMMAND" "$?"' ERR

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {

    initialize_logger

    print_banner

    log_info "TinQa Deployment Started"

    collect_system_information

    cleanup_pi

    transfer_project

    install_system_packages

    create_python_environment

    install_python_packages

    configure_bluetooth

    validate_system

    install_systemd_service

    health_check

    finish_deployment

}

main "$@"