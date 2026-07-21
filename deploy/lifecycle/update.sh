#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${DEPLOY_ROOT}/core/prompts.sh"
source "${DEPLOY_ROOT}/core/updater.sh"
source "${DEPLOY_ROOT}/core/checkpoint.sh"
source "${DEPLOY_ROOT}/core/reboot.sh"

checkpoint_set CURRENT_STAGE UPDATE

echo
echo "=============================================="
echo "Operating System Update"
echo "=============================================="

if ask_yes_no "Check for updates?"
then

    perform_system_update

    if [[ -f /var/run/reboot-required ]]
    then

        request_reboot

    fi

fi