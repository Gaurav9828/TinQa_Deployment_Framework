#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File : verify.sh
#
# Verifies the complete deployment framework.
#
###############################################################################

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN="\033[32m"
RED="\033[31m"
BLUE="\033[36m"
YELLOW="\033[33m"
RESET="\033[0m"

PASS=0
FAIL=0

section() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

run() {

    local title="$1"
    shift

    printf "%-80s" "$title"

    if "$@" >/dev/null 2>&1
    then
        echo -e " ${GREEN}[PASS]${RESET}"
        ((++PASS))
    else
        echo -e " ${RED}[FAIL]${RESET}"
        ((++FAIL))
    fi

}

###############################################################################
section "1. Bash Syntax"
###############################################################################

while IFS= read -r file
do
    run "$file" bash -n "$file"
done < <(
find "$ROOT/deploy" -name "*.sh" \
| sed "s|$ROOT/||" \
| sort
)
###############################################################################
section "2. Mock Deployment"
###############################################################################

run "Mock Deployment" bash "$ROOT/deploy/tests/run_deploy.sh"

###############################################################################
section "3. Unit Tests"
###############################################################################

run "Framework Tests" bash "$ROOT/deploy/tests/run_tests.sh"

###############################################################################
section "Summary"
###############################################################################

echo
echo "Passed : $PASS"
echo "Failed : $FAIL"

echo

if [[ $FAIL -eq 0 ]]
then
    echo -e "${GREEN}Framework verification PASSED${RESET}"
    exit 0
fi

echo -e "${RED}Framework verification FAILED${RESET}"
exit 1