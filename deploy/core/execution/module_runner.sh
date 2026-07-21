#!/usr/bin/env bash
###############################################################################
#
# Generic Module Runner
#
###############################################################################

set -Eeuo pipefail

source "${DEPLOY_ROOT}/core/repair.sh"

run_module() {

    local module="$1"

    echo
    echo "=============================================================="
    echo "Executing ${module}"
    echo "=============================================================="
    echo

    "${module}"

    local validator="validate_${module#run_}"

    if declare -F "${validator}" >/dev/null
    then
        echo
        echo "Running Validation..."
        echo

        if "${validator}"
        then
            echo "[PASS] Validation successful."
            return 0
        fi

        echo
        echo "[WARN] Validation failed."
        echo "[INFO] Attempting automatic repair..."
        echo

        repair_execute "${module#run_}"

        echo
        echo "Retrying..."
        echo

        "${module}"

        if "${validator}"
        then
            echo "[PASS] Validation successful after repair."
            return 0
        fi

        echo "[FAIL] Validation failed after repair."

        return 1
    fi

    return 0
}

export -f run_module