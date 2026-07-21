#!/usr/bin/env bash
###############################################################################
#
# Repair Engine
#
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

repair_execute() {

    local repair="$1"

    local script="${DEPLOY_ROOT}/repair/${repair}.sh"

    if [[ ! -f "${script}" ]]; then
        echo "[REPAIR] No repair module for ${repair}"
        return 1
    fi

    source "${script}"

    local function="repair_${repair}"

    if declare -F "${function}" >/dev/null; then

        echo
        echo "========================================================="
        echo "Running Repair : ${repair}"
        echo "========================================================="
        echo

        "${function}"
        return $?
    fi

    return 1
}

export -f repair_execute