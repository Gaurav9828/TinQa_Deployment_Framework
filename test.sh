#!/usr/bin/env bash

set -e

NEW_BASH="$(brew --prefix)/bin/bash"

exec "$NEW_BASH" deploy/tests/run_deploy.sh "$@"