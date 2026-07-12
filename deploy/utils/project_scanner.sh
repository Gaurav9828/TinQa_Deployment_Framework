#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : project_scanner.sh
#
# Description :
# Dynamically scans and compares project structures.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Dependencies
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${DEPLOY_ROOT}/core/logger.sh"
source "${DEPLOY_ROOT}/config/excludes.conf"

###############################################################################
# Scan Project Structure
###############################################################################

scan_project_structure() {

    local root="$1"

    (
        cd "${root}" || exit 1

        find . -print |
        sed 's|^\./||' |
        sort |
        while IFS= read -r item
        do
            [[ -z "${item}" ]] && continue

            local skip=0
            local pattern

            for pattern in "${EXCLUDED_PATTERNS[@]:-}"
            do
                #
                # Match:
                #   .coverage
                #   *.pyc
                #   __pycache__
                #   __pycache__/...
                #   venv
                #   venv/...
                #   logs
                #   logs/...
                #

                if [[ "${item}" == ${pattern} || "${item}" == ${pattern}/* || "${item}" == */${pattern} || "${item}" == */${pattern}/* ]]
                then
                    skip=1
                    break
                fi
            done

            (( skip )) && continue

            printf '%s\n' "${item}"

        done
    )

}

###############################################################################
# Compare Project Structure
###############################################################################

compare_project_structure() {

    local source_root="$1"
    local destination_root="$2"

    log_info "Comparing deployed project structure..."

    local failed=0

    while IFS= read -r item
    do

        [[ -z "${item}" ]] && continue

        if [[ -e "${destination_root}/${item}" ]]
        then

            log_success "Found : ${item}"

        else

            log_error "Missing : ${item}"

            failed=1

        fi

    done < <(scan_project_structure "${source_root}")

    return "${failed}"

}

###############################################################################
# Public API
###############################################################################

export -f scan_project_structure
export -f compare_project_structure