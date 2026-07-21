#!/usr/bin/env bash
###############################################################################
#
# Preflight
#
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${DEPLOY_ROOT}/core/plugin.sh"

echo
echo "============================================================"
echo "               PRE-FLIGHT INSPECTION"
echo "============================================================"

plugin_execute_directory "${DEPLOY_ROOT}/inspectors"

echo
echo "Preflight inspection completed."
echo