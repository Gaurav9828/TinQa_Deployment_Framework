#!/usr/bin/env bash
###############################################################################
#
# Module 13 - Health Report
#
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${DEPLOY_ROOT}/core/reporting/health_report.sh"

###############################################################################

run_13_health_report() {

    section "Module 13 - Health Report"

    health_report_execute

    log_success "Health report generated."

}

export -f run_13_health_report