#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : run_deploy.sh
# Version     : 1.0.0
#
# Description :
# Executes the real deployment framework in TEST mode.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Directories
###############################################################################

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEPLOY_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"

###############################################################################
# Test Mode
###############################################################################

export DEPLOY_MODE="TEST"

export MOCK_VERBOSE=1
export MOCK_FAIL=0
export MOCK_DELAY=0

export TEST_ROOT

export SANDBOX_ROOT="${TEST_ROOT}/sandbox"

###############################################################################
# Mock Commands
###############################################################################

source "${TEST_ROOT}/mock_commands.sh"

###############################################################################
# Initialize Fake Raspberry Pi
###############################################################################

source "${TEST_ROOT}/fake_pi.sh"

source "${TEST_ROOT}/fixtures/filesystem.sh"

source "${TEST_ROOT}/fixtures/python.sh"

source "${TEST_ROOT}/fixtures/bluetooth.sh"

source "${TEST_ROOT}/fixtures/systemd.sh"

initialize_fake_pi

mock_initialize

initialize_filesystem

initialize_python

initialize_bluetooth

initialize_systemd

###############################################################################
# Execute Real Deployment
###############################################################################

bash "${DEPLOY_ROOT}/deploy.sh"