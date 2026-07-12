#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : run_tests.sh
# Version     : 1.0.0
#
# Description :
# Executes the complete TinQa Deployment Test Suite.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Directories
###############################################################################

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPORT_DIR="${TEST_DIR}/reports"

CASE_DIR="${TEST_DIR}/cases"

###############################################################################
# Dependencies
###############################################################################

source "${TEST_DIR}/assertions.sh"

source "${TEST_DIR}/mock_commands.sh"

source "${TEST_DIR}/fake_pi.sh"

source "${TEST_DIR}/fixtures/filesystem.sh"

source "${TEST_DIR}/fixtures/python.sh"

source "${TEST_DIR}/fixtures/bluetooth.sh"

source "${TEST_DIR}/fixtures/systemd.sh"

###############################################################################
# Banner
###############################################################################

show_banner() {

cat <<EOF

===============================================================================

                     TinQa Deployment Framework

                          Regression Test Suite

===============================================================================

EOF

}

###############################################################################
# Initialize Test Environment
###############################################################################

initialize_environment() {

    info "Initializing Fake Raspberry Pi..."

    initialize_fake_pi

    initialize_filesystem

    initialize_python

    initialize_bluetooth

    initialize_systemd

    fake_pi_summary

}

###############################################################################
# Execute Test Case
###############################################################################

run_case() {

    local file="$1"

    info "Running $(basename "${file}")"

    bash "${file}"

    echo

}

###############################################################################
# Execute All Cases
###############################################################################

run_all_cases() {

    local file

    for file in "${CASE_DIR}"/*.sh
    do

        [[ -f "${file}" ]] || continue

        run_case "${file}"

    done

}

###############################################################################
# Cleanup
###############################################################################

cleanup_environment() {

    info "Cleaning sandbox..."

    reset_fake_pi

}

###############################################################################
# Main
###############################################################################

main() {

    reset_tests

    show_banner

    initialize_environment

    run_all_cases

    test_summary

    cleanup_environment

}

###############################################################################
# Execute
###############################################################################

main "$@"