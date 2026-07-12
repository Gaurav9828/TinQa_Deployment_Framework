#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File : utils.sh
#
# Version : 1.0.0
#
# Description :
#
# Shared utility functions used throughout the deployment framework.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Version
###############################################################################

readonly UTILS_VERSION="1.0.0"

###############################################################################
# Platform Detection
###############################################################################

OS_NAME="$(uname -s)"

ARCH_NAME="$(uname -m)"

###############################################################################
# Detect Linux
###############################################################################

is_linux() {

    [[ "${OS_NAME}" == "Linux" ]]

}

###############################################################################
# Detect macOS
###############################################################################

is_macos() {

    [[ "${OS_NAME}" == "Darwin" ]]

}

###############################################################################
# Detect Raspberry Pi
###############################################################################

is_pi() {

    [[ -f /proc/device-tree/model ]] || return 1

    grep -qi "Raspberry" \
        /proc/device-tree/model

}

###############################################################################
# Root Check
###############################################################################

require_root() {

    [[ "$(id -u)" -eq 0 ]]

}

###############################################################################
# Command Exists
###############################################################################

command_exists() {

    command -v "$1" >/dev/null 2>&1

}

###############################################################################
# Require Command
###############################################################################

require_command() {

    local cmd="$1"

    command_exists "${cmd}"

}

###############################################################################
# Internet Connectivity
###############################################################################

require_network() {

    ping -c 1 8.8.8.8 >/dev/null 2>&1

}

###############################################################################
# Filesystem Utilities
###############################################################################

###############################################################################
# Creates directory if it doesn't exist
#
# Usage:
#   create_dir "/tmp/test"
###############################################################################

create_dir() {

    local directory="$1"

    [[ -z "${directory}" ]] && return 1

    mkdir -p "${directory}"

}

###############################################################################
# Safely removes file or directory
#
# Usage:
#   safe_rm "/tmp/file"
###############################################################################

safe_rm() {

    local target="$1"

    [[ -z "${target}" ]] && return 1

    [[ ! -e "${target}" ]] && return 0

    rm -rf -- "${target}"

}

###############################################################################
# Safely copies files/directories
#
# Usage:
#   safe_cp source destination
###############################################################################

safe_cp() {

    local source="$1"
    local destination="$2"

    [[ ! -e "${source}" ]] && return 1

    cp -Rf -- "${source}" "${destination}"

}

###############################################################################
# Safely moves files/directories
#
# Usage:
#   safe_mv source destination
###############################################################################

safe_mv() {

    local source="$1"
    local destination="$2"

    [[ ! -e "${source}" ]] && return 1

    mv -f -- "${source}" "${destination}"

}

###############################################################################
# Creates empty file
#
# Usage:
#   create_file "/tmp/demo.txt"
###############################################################################

create_file() {

    local file="$1"

    mkdir -p "$(dirname "${file}")"

    touch "${file}"

}

###############################################################################
# Check file exists
###############################################################################

file_exists() {

    [[ -f "$1" ]]

}

###############################################################################
# Check directory exists
###############################################################################

directory_exists() {

    [[ -d "$1" ]]

}

###############################################################################
# Safe chmod
#
# Usage:
#   safe_chmod 755 file
###############################################################################

safe_chmod() {

    local permission="$1"
    local target="$2"

    [[ ! -e "${target}" ]] && return 1

    chmod "${permission}" "${target}"

}

###############################################################################
# Safe chown
#
# Usage:
#   safe_chown pi:pi file
###############################################################################

safe_chown() {

    local owner="$1"
    local target="$2"

    [[ ! -e "${target}" ]] && return 1

    chown "${owner}" "${target}"

}

###############################################################################
# Returns file size (bytes)
###############################################################################

file_size() {

    local file="$1"

    [[ ! -f "${file}" ]] && return 1

    stat -c%s "${file}"

}

###############################################################################
# Returns directory size (human readable)
###############################################################################

directory_size() {

    local directory="$1"

    [[ ! -d "${directory}" ]] && return 1

    du -sh "${directory}" | cut -f1

}

###############################################################################
# Creates symbolic link
#
# Usage:
#   create_symlink source destination
###############################################################################

create_symlink() {

    local source="$1"
    local destination="$2"

    ln -sfn "${source}" "${destination}"

}

###############################################################################
# Service Utilities
###############################################################################

###############################################################################
# Checks whether a systemd service exists.
#
# Usage:
#   service_exists ssh
###############################################################################

service_exists() {

    local service="$1"

    systemctl list-unit-files --type=service \
        | awk '{print $1}' \
        | grep -Fxq "${service}.service"

}

###############################################################################
# Checks whether a service is currently active.
#
# Returns:
#   0 -> Active
#   1 -> Not Active
###############################################################################

service_running() {

    local service="$1"

    systemctl is-active --quiet "${service}"

}

###############################################################################
# Starts a service.
###############################################################################

start_service() {

    local service="$1"

    sudo systemctl start "${service}"

}

###############################################################################
# Stops a service.
###############################################################################

stop_service() {

    local service="$1"

    sudo systemctl stop "${service}"

}

###############################################################################
# Restarts a service.
###############################################################################

restart_service() {

    local service="$1"

    sudo systemctl restart "${service}"

}

###############################################################################
# Enables a service.
###############################################################################

enable_service() {

    local service="$1"

    sudo systemctl enable "${service}"

}

###############################################################################
# Disables a service.
###############################################################################

disable_service() {

    local service="$1"

    sudo systemctl disable "${service}"

}

###############################################################################
# Reloads systemd daemon.
###############################################################################

reload_systemd() {

    sudo systemctl daemon-reload

}

###############################################################################
# Waits until a service becomes active.
#
# Usage:
#   wait_for_service bluetooth 30
###############################################################################

wait_for_service() {

    local service="$1"
    local timeout="${2:-30}"

    local elapsed=0

    while (( elapsed < timeout ))
    do

        if service_running "${service}"
        then
            return 0
        fi

        sleep 1

        ((++elapsed))

    done

    return 1

}

###############################################################################
# Waits until a service stops.
###############################################################################

wait_for_service_stop() {

    local service="$1"
    local timeout="${2:-30}"

    local elapsed=0

    while (( elapsed < timeout ))
    do

        if ! service_running "${service}"
        then
            return 0
        fi

        sleep 1

        ((++elapsed))

    done

    return 1

}

###############################################################################
# Process Utilities
###############################################################################

###############################################################################
# Returns success if process exists.
#
# Usage:
#   process_running bluetoothd
###############################################################################

process_running() {

    local process="$1"

    pgrep -x "${process}" >/dev/null 2>&1

}

###############################################################################
# Returns PID(s) of a process.
###############################################################################

process_pid() {

    local process="$1"

    pgrep -x "${process}"

}

###############################################################################
# Terminates a process gracefully.
###############################################################################

kill_process() {

    local process="$1"

    pkill -TERM -x "${process}" 2>/dev/null || true

}

###############################################################################
# Force kills a process.
###############################################################################

force_kill_process() {

    local process="$1"

    pkill -KILL -x "${process}" 2>/dev/null || true

}

###############################################################################
# Waits until a process exits.
###############################################################################

wait_for_process_exit() {

    local process="$1"
    local timeout="${2:-20}"

    local elapsed=0

    while (( elapsed < timeout ))
    do

        if ! process_running "${process}"
        then
            return 0
        fi

        sleep 1

        ((++elapsed))

    done

    return 1

}

###############################################################################
# Download Utilities
###############################################################################

###############################################################################
# Download a file
#
# Usage:
# download URL DESTINATION
###############################################################################

download() {

    local url="$1"
    local destination="$2"

    if command_exists curl; then

        curl \
            --fail \
            --location \
            --silent \
            --show-error \
            "${url}" \
            -o "${destination}"

    elif command_exists wget; then

        wget \
            -q \
            "${url}" \
            -O "${destination}"

    else

        return 1

    fi

}

###############################################################################
# Download with retry
###############################################################################

download_with_retry() {

    local url="$1"
    local destination="$2"

    local retries="${3:-3}"

    local count=1

    until download "${url}" "${destination}"
    do

        if (( count >= retries ))
        then
            return 1
        fi

        sleep 2

        ((++count))

    done

}

###############################################################################
# SHA256
###############################################################################

sha256() {

    local file="$1"

    sha256sum "${file}" | awk '{print $1}'

}

###############################################################################
# Verify SHA256
###############################################################################

verify_sha256() {

    local file="$1"

    local expected="$2"

    [[ "$(sha256 "${file}")" == "${expected}" ]]

}

###############################################################################
# Archive Extraction
###############################################################################

extract_archive() {

    local archive="$1"

    local destination="$2"

    mkdir -p "${destination}"

    case "${archive}" in

        *.tar.gz|*.tgz)

            tar -xzf "${archive}" -C "${destination}"

            ;;

        *.tar.xz)

            tar -xJf "${archive}" -C "${destination}"

            ;;

        *.zip)

            unzip -oq "${archive}" -d "${destination}"

            ;;

        *)

            return 1

            ;;

    esac

}

###############################################################################
# Temporary Files
###############################################################################

create_temp_file() {

    mktemp

}

create_temp_directory() {

    mktemp -d

}

###############################################################################
# Spinner
###############################################################################

spinner() {

    local pid="$1"

    local spin='-\|/'

    local i=0

    while kill -0 "${pid}" 2>/dev/null
    do

        printf "\r[%c] Working..." "${spin:i++%4:1}"

        sleep 0.1

    done

    printf "\r"

}

###############################################################################
# Progress Bar
###############################################################################

progress() {

    local current="$1"

    local total="$2"

    local width=40

    local filled=$(( current * width / total ))

    local empty=$(( width - filled ))

    printf "\r["

    printf "%0.s#" $(seq 1 "${filled}")

    printf "%0.s-" $(seq 1 "${empty}")

    printf "] %3d%%" $(( current * 100 / total ))

    if (( current == total ))
    then
        printf "\n"
    fi

}

###############################################################################
# Cleanup Helpers
###############################################################################

cleanup_directory() {

    local directory="$1"

    [[ -d "${directory}" ]] || return 0

    find "${directory}" -mindepth 1 -delete

}

cleanup_temp_files() {

    find /tmp \
        -maxdepth 1 \
        -user "$(whoami)" \
        -name "tmp.*" \
        -mtime +1 \
        -delete 2>/dev/null || true

}

###############################################################################
# Public API Export
###############################################################################

export -f \
    is_linux \
    is_macos \
    is_pi \
    require_root \
    require_command \
    require_network \
    command_exists \
    create_dir \
    create_file \
    safe_rm \
    safe_cp \
    safe_mv \
    safe_chmod \
    safe_chown \
    file_exists \
    directory_exists \
    file_size \
    directory_size \
    create_symlink \
    service_exists \
    service_running \
    start_service \
    stop_service \
    restart_service \
    enable_service \
    disable_service \
    reload_systemd \
    wait_for_service \
    wait_for_service_stop \
    process_running \
    process_pid \
    kill_process \
    force_kill_process \
    wait_for_process_exit \
    download \
    download_with_retry \
    sha256 \
    verify_sha256 \
    extract_archive \
    create_temp_file \
    create_temp_directory \
    spinner \
    progress \
    cleanup_directory \
    cleanup_temp_files