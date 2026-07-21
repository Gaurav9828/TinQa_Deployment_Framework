#!/usr/bin/env bash

set -Eeuo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/checkpoint.sh"

resume_deployment() {

    local stage

    stage=$(checkpoint_get CURRENT_STAGE)

    [[ -z "${stage}" ]] && return

    echo

    echo "=========================================="

    echo "Resuming deployment"

    echo "Stage : ${stage}"

    echo "=========================================="

    echo

}

export -f resume_deployment