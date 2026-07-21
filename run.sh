#!/usr/bin/env bash

set -e

NEW_BASH="$(brew --prefix)/bin/bash"

exec "$NEW_BASH" deploy/deploy.sh "$@"