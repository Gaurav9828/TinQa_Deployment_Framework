#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Configuration
###############################################################################

set -Eeuo pipefail

###############################################################################
# Framework
###############################################################################

readonly FRAMEWORK_NAME="TinQa Deployment Framework"
readonly FRAMEWORK_VERSION="1.0.0"

###############################################################################
# Raspberry Pi
###############################################################################

readonly PI_USER="pi"
readonly PI_HOST="192.168.29.170"
readonly PI_PORT="22"

readonly SSH_TARGET="${PI_USER}@${PI_HOST}"

###############################################################################
# Project
###############################################################################

readonly PROJECT_NAME="TinQa_Weather_Sync_System"

readonly LOCAL_PROJECT_DIR="/Users/gaurav/Desktop/TinQa/${PROJECT_NAME}"

readonly REMOTE_PROJECT_DIR="/home/${PI_USER}/${PROJECT_NAME}"

###############################################################################
# Service
###############################################################################

readonly SERVICE_NAME="tinqa.service"

###############################################################################
# Python
###############################################################################

readonly PYTHON_EXECUTABLE="python3"

readonly VENV_NAME="venv"

readonly REMOTE_VENV="${REMOTE_PROJECT_DIR}/${VENV_NAME}"

readonly REQUIREMENTS_FILE="requirements.txt"

###############################################################################
# Bluetooth
###############################################################################

readonly BLUETOOTH_SERVICE="bluetooth"

###############################################################################
# Logging
###############################################################################

readonly LOG_DIRECTORY="logs"

readonly LOG_TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"

readonly LOG_FILE="${LOG_DIRECTORY}/deploy_${LOG_TIMESTAMP}.log"

###############################################################################
# Transfer
###############################################################################

readonly RSYNC_EXCLUDES=(
    "__pycache__"
    "venv"
    ".git"
    ".pytest_cache"
    ".DS_Store"
    "htmlcov"
    ".coverage"
    ".idea"
    ".vscode"
)

###############################################################################
# Timeouts
###############################################################################

readonly SSH_CONNECT_TIMEOUT=10

readonly SSH_COMMAND_TIMEOUT=600

readonly SERVICE_STARTUP_WAIT=5

###############################################################################
# Retry Policy
###############################################################################

readonly MAX_RETRIES=3

readonly RETRY_DELAY=2

###############################################################################
# Feature Flags
###############################################################################

readonly ENABLE_SYSTEM_UPDATE=true

readonly ENABLE_PACKAGE_INSTALL=true

readonly ENABLE_BLUETOOTH_SETUP=true

readonly ENABLE_RUNTIME_VALIDATION=true

readonly ENABLE_HEALTH_REPORT=true

readonly ENABLE_DEPLOYMENT_REPORT=true

###############################################################################
# Colors
###############################################################################

readonly ENABLE_COLOR_OUTPUT=true

###############################################################################
# SSH Options
###############################################################################

readonly SSH_OPTIONS=(
    -p "${PI_PORT}"
    -o ConnectTimeout="${SSH_CONNECT_TIMEOUT}"
    -o ServerAliveInterval=30
    -o ServerAliveCountMax=3
)

###############################################################################
# Rsync Options
###############################################################################

readonly RSYNC_OPTIONS=(
    -az
    --delete
)

###############################################################################
# End of Configuration
###############################################################################