#!/usr/bin/env bash
###############################################################################
#
# Module Registry
#
###############################################################################

set -Eeuo pipefail

MODULES=()

register_module() {

    MODULES+=("$1")

}

list_modules() {

    printf "%s\n" "${MODULES[@]}"

}

module_count() {

    echo "${#MODULES[@]}"

}

export -f register_module
export -f list_modules
export -f module_count