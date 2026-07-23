#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export TINQA_LAUNCHER=1
export DEPLOY_MODE=PRODUCTION

exec "${ROOT_DIR}/deploy/deploy.sh" "$@"