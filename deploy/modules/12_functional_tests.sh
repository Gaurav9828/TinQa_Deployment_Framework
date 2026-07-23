#!/usr/bin/env bash
###############################################################################
#
# Module 12 - Functional Tests
#
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${DEPLOY_ROOT}/core/testing/functional_tests.sh"

###############################################################################

run_12_functional_tests() {

    section "Module 12 - Functional Tests"

    functional_tests_execute

    log_success "Functional tests completed."

}

export -f run_12_functional_tests