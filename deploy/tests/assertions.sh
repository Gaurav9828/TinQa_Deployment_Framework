#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : assertions.sh
# Version     : 1.0.0
#
# Description :
# Common assertion library used by all deployment tests.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Test Counters
###############################################################################

TEST_TOTAL=0

TEST_PASSED=0

TEST_FAILED=0

###############################################################################
# Colors
###############################################################################

GREEN="\033[0;32m"

RED="\033[0;31m"

YELLOW="\033[1;33m"

BLUE="\033[0;34m"

RESET="\033[0m"

###############################################################################
# PASS
###############################################################################

pass() {

    local message="$1"

    ((++TEST_TOTAL))

      ((++TEST_PASSED))

    printf "${GREEN}[PASS]${RESET} %s\n" "${message}"

}

###############################################################################
# FAIL
###############################################################################

fail() {

    local message="$1"

    ((++TEST_TOTAL))

    ((++TEST_FAILED))

    printf "${RED}[FAIL]${RESET} %s\n" "${message}"

}

###############################################################################
# INFO
###############################################################################

info() {

    printf "${BLUE}[INFO]${RESET} %s\n" "$1"

}

###############################################################################
# WARNING
###############################################################################

warning() {

    printf "${YELLOW}[WARN]${RESET} %s\n" "$1"

}

###############################################################################
# Assert True
###############################################################################

assert_true() {

    local description="$1"

    shift

    if "$@"
    then

        pass "${description}"

    else

        fail "${description}"

    fi

}

###############################################################################
# Assert False
###############################################################################

assert_false() {

    local description="$1"

    shift

    if "$@"
    then

        fail "${description}"

    else

        pass "${description}"

    fi

}

###############################################################################
# Assert File Exists
###############################################################################

assert_file_exists() {

    local file="$1"

    if [[ -f "${file}" ]]
    then

        pass "File exists : ${file}"

    else

        fail "File missing : ${file}"

    fi

}

###############################################################################
# Assert Directory Exists
###############################################################################

assert_directory_exists() {

    local directory="$1"

    if [[ -d "${directory}" ]]
    then

        pass "Directory exists : ${directory}"

    else

        fail "Directory missing : ${directory}"

    fi

}

###############################################################################
# Assert Command Exists
###############################################################################

assert_command_exists() {

    local command="$1"

    if command -v "${command}" >/dev/null 2>&1
    then

        pass "Command found : ${command}"

    else

        fail "Command missing : ${command}"

    fi

}

###############################################################################
# Assert Exit Code
###############################################################################

assert_exit_code() {

    local expected="$1"

    local actual="$2"

    if [[ "${expected}" -eq "${actual}" ]]
    then

        pass "Exit code ${expected}"

    else

        fail "Expected exit ${expected}, got ${actual}"

    fi

}

###############################################################################
# Assert Equal
###############################################################################

assert_equal() {

    local expected="$1"

    local actual="$2"

    local description="$3"

    if [[ "${expected}" == "${actual}" ]]
    then

        pass "${description}"

    else

        fail "${description}"

    fi

}

###############################################################################
# Assert Not Empty
###############################################################################

assert_not_empty() {

    local value="$1"

    local description="$2"

    if [[ -n "${value}" ]]
    then

        pass "${description}"

    else

        fail "${description}"

    fi

}

###############################################################################
# Assert Empty
###############################################################################

assert_empty() {

    local value="$1"

    local description="$2"

    if [[ -z "${value}" ]]
    then

        pass "${description}"

    else

        fail "${description}"

    fi

}

###############################################################################
# Print Summary
###############################################################################

test_summary() {

    echo

    echo "=============================================================="

    printf "Tests Executed : %d\n" "${TEST_TOTAL}"

    printf "Passed         : %d\n" "${TEST_PASSED}"

    printf "Failed         : %d\n" "${TEST_FAILED}"

    echo "=============================================================="

    echo

    if [[ "${TEST_FAILED}" -eq 0 ]]
    then

        printf "${GREEN}ALL TESTS PASSED${RESET}\n"

        return 0

    fi

    printf "${RED}TEST FAILURES DETECTED${RESET}\n"

    return 1

}

###############################################################################
# Reset Counters
###############################################################################

reset_tests() {

    TEST_TOTAL=0

    TEST_PASSED=0

    TEST_FAILED=0

}

###############################################################################
# Public API
###############################################################################

export -f \
    pass \
    fail \
    info \
    warning \
    assert_true \
    assert_false \
    assert_file_exists \
    assert_directory_exists \
    assert_command_exists \
    assert_exit_code \
    assert_equal \
    assert_not_empty \
    assert_empty \
    test_summary \
    reset_tests