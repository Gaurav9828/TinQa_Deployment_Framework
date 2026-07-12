#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : config.sh
# Version     : 1.0.0
#
# Description :
# Central configuration for the deployment framework.
#
# NOTE:
# Never hardcode any configurable value outside this file.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# FRAMEWORK
###############################################################################

readonly FRAMEWORK_NAME="TinQa Deployment Framework"

readonly FRAMEWORK_VERSION="1.0.0"

readonly FRAMEWORK_AUTHOR="Gaurav Srivastava"

###############################################################################
# PROJECT
###############################################################################

readonly PROJECT_NAME="TinQa Weather Sync System"

readonly PROJECT_FOLDER="TinQa_Weather_Sync_System"

###############################################################################
# USERS
###############################################################################

readonly DEFAULT_USER="pi"

readonly DEFAULT_GROUP="pi"

###############################################################################
# NETWORK
###############################################################################

readonly DEFAULT_SSH_PORT=22

readonly NETWORK_TEST_HOST="8.8.8.8"

readonly NETWORK_TIMEOUT=5

###############################################################################
# PYTHON
###############################################################################

readonly PYTHON_BINARY="python3"

readonly PIP_BINARY="pip"

readonly VENV_FOLDER="venv"

###############################################################################
# Project Root
###############################################################################

if [[ "${DEPLOY_MODE:-PRODUCTION}" == "TEST" ]]; then

    readonly PROJECT_ROOT="${FAKE_PI_ROOT}/opt/tinqa"

else

    readonly PROJECT_ROOT="/opt/tinqa"

fi

export PROJECT_ROOT

###############################################################################
# PROJECT PATHS
###############################################################################

readonly VENV_PATH="${PROJECT_ROOT}/${VENV_FOLDER}"

readonly LOG_DIRECTORY="${PROJECT_ROOT}/logs"

###############################################################################
# SYSTEM PATHS
###############################################################################

if [[ "${DEPLOY_MODE:-PRODUCTION}" == "TEST" ]]
then

    readonly SYSTEMD_DIRECTORY="${FAKE_PI_ROOT}/etc/systemd/system"

    readonly SUDOERS_DIRECTORY="${FAKE_PI_ROOT}/etc/sudoers.d"

    readonly BLUETOOTH_DIRECTORY="${FAKE_PI_ROOT}/var/lib/bluetooth"
    

else

    readonly SYSTEMD_DIRECTORY="/etc/systemd/system"

    readonly SUDOERS_DIRECTORY="/etc/sudoers.d"

    readonly BLUETOOTH_DIRECTORY="/var/lib/bluetooth"

fi

readonly SYSTEMD_SERVICE="tinqa.service"

readonly SYSTEMD_FILE="${SYSTEMD_DIRECTORY}/${SYSTEMD_SERVICE}"

###############################################################################
# DEPLOYMENT
###############################################################################

readonly DEPLOYMENT_TIMEOUT=300

readonly SERVICE_START_TIMEOUT=30

readonly RETRY_COUNT=3

readonly RETRY_DELAY=2

###############################################################################
# LOGGING
###############################################################################

readonly LOG_LEVEL="INFO"

readonly DEBUG_MODE=0

readonly KEEP_LOG_HISTORY=20

###############################################################################
# COLORS
###############################################################################

readonly RESET="\033[0m"

readonly RED="\033[31m"

readonly GREEN="\033[32m"

readonly YELLOW="\033[33m"

readonly BLUE="\033[34m"

readonly MAGENTA="\033[35m"

readonly CYAN="\033[36m"

readonly WHITE="\033[37m"


###############################################################################
# REQUIRED COMMANDS
###############################################################################

REQUIRED_COMMANDS=(

    ssh

    rsync

    python3

    pip

    systemctl

    nmcli

    bluetoothctl

    curl

    git

)

###############################################################################
# SUPPORTED OPERATING SYSTEMS
###############################################################################

SUPPORTED_OS=(

    Linux

)

###############################################################################
# SUPPORTED ARCHITECTURES
###############################################################################

SUPPORTED_ARCH=(

    armv7l

    aarch64

)

###############################################################################
# BLUETOOTH
###############################################################################

BLUETOOTH_DEVICE="hci0"

BLUETOOTH_DISCOVERY_TIMEOUT=15

###############################################################################
# NETWORK MANAGER
###############################################################################

NMCLI_BINARY="nmcli"

NETWORK_INTERFACE="wlan0"

###############################################################################
# SYSTEMD
###############################################################################

SYSTEMD_UNIT_NAME="tinqa"

SYSTEMD_RESTART_POLICY="always"

SYSTEMD_RESTART_SEC=5

###############################################################################
# SSH
###############################################################################

SSH_OPTIONS=(

    -o StrictHostKeyChecking=no

    -o UserKnownHostsFile=/dev/null

)

###############################################################################
# DEPLOYMENT FLAGS
###############################################################################

ENABLE_BLUETOOTH=true

ENABLE_NETWORK_MANAGER=true

ENABLE_SYSTEMD_SERVICE=true

ENABLE_ROLLBACK=true

ENABLE_HEALTH_CHECK=true

ENABLE_LOG_ROTATION=true

ENABLE_CLEAN_DEPLOYMENT=true

###############################################################################
# FEATURE FLAGS
###############################################################################

FEATURE_BLUETOOTH=1
FEATURE_NETWORK_MANAGER=1
FEATURE_SYSTEMD=1
FEATURE_ROLLBACK=1
FEATURE_HEALTH_CHECK=1
FEATURE_DIAGNOSTICS=1
FEATURE_AUTO_RECOVERY=1

###############################################################################
# RUNTIME VARIABLES
#
# These values are populated during deployment.
###############################################################################

TARGET_HOST=""
TARGET_IP=""
TARGET_PORT="${DEFAULT_SSH_PORT}"

CURRENT_STAGE=""
CURRENT_MODULE=""
CURRENT_STEP=""

DEPLOYMENT_STATUS="NOT_STARTED"

DEPLOYMENT_START_TIME=0
DEPLOYMENT_END_TIME=0

###############################################################################
# VALIDATION
###############################################################################

validate_configuration() {

    local failed=0

    [[ -z "${PROJECT_NAME}" ]] && failed=1

    [[ -z "${PROJECT_ROOT}" ]] && failed=1

    [[ -z "${DEFAULT_USER}" ]] && failed=1

    [[ -z "${PYTHON_BINARY}" ]] && failed=1

    [[ -z "${SYSTEMD_SERVICE}" ]] && failed=1

    [[ ${#REQUIRED_COMMANDS[@]} -eq 0 ]] && failed=1

    [[ ${#SUPPORTED_OS[@]} -eq 0 ]] && failed=1

    return "${failed}"

}

###############################################################################
# Initialize Configuration
###############################################################################

initialize_configuration() {

    validate_configuration

    return 0

}

###############################################################################
# Public API
###############################################################################

export -f initialize_configuration

###############################################################################
# CONFIGURATION SUMMARY
###############################################################################

print_configuration() {

cat <<EOF

================ Configuration ================

Framework          : ${FRAMEWORK_NAME}
Framework Version  : ${FRAMEWORK_VERSION}

Project            : ${PROJECT_NAME}
Folder             : ${PROJECT_FOLDER}

Default User       : ${DEFAULT_USER}

Python             : ${PYTHON_BINARY}

Virtual Env        : ${VENV_PATH}

Systemd            : ${SYSTEMD_FILE}

Deployment Timeout : ${DEPLOYMENT_TIMEOUT}

Retry Count        : ${RETRY_COUNT}

Bluetooth          : ${ENABLE_BLUETOOTH}

Rollback           : ${ENABLE_ROLLBACK}

Health Check       : ${ENABLE_HEALTH_CHECK}

===============================================

EOF

}

###############################################################################
# FEATURE DETECTION
###############################################################################

feature_enabled() {

    local feature="$1"

    case "${feature}" in

        bluetooth)

            [[ "${ENABLE_BLUETOOTH}" == true ]]

            ;;

        rollback)

            [[ "${ENABLE_ROLLBACK}" == true ]]

            ;;

        diagnostics)

            [[ "${FEATURE_DIAGNOSTICS}" -eq 1 ]]

            ;;

        health)

            [[ "${ENABLE_HEALTH_CHECK}" == true ]]

            ;;

        systemd)

            [[ "${ENABLE_SYSTEMD_SERVICE}" == true ]]

            ;;

        network)

            [[ "${ENABLE_NETWORK_MANAGER}" == true ]]

            ;;

        *)

            return 1

            ;;

    esac

}

###############################################################################
# CONFIG VERSION
###############################################################################

config_version() {

    echo "${FRAMEWORK_VERSION}"

}

###############################################################################
# EXPORTS
###############################################################################

export PROJECT_NAME
export PROJECT_FOLDER

export PROJECT_ROOT
export VENV_PATH
export LOG_DIRECTORY

export DEFAULT_USER
export DEFAULT_GROUP

export PYTHON_BINARY
export PIP_BINARY

export SYSTEMD_SERVICE
export SYSTEMD_FILE

export NETWORK_TEST_HOST

export DEBUG_MODE

###############################################################################
# SELF TEST
###############################################################################

config_self_test() {

    validate_configuration || return 1

    return 0

}