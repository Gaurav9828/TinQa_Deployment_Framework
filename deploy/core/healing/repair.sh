#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : repair.sh
# Version     : 1.0.0
#
# Description :
# Centralized Self-Healing Engine
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Dependencies
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${DEPLOY_ROOT}/core/logger.sh"
source "${DEPLOY_ROOT}/core/remote.sh"

###############################################################################
# Generic Repair Executor
###############################################################################

repair_execute() {

    local title="$1"
    shift

    log_info "Repair : ${title}"

    if "$@"
    then
        log_success "${title} repaired."
        return 0
    fi

    log_warning "${title} repair unsuccessful."

    return 1

}

###############################################################################
# Network
###############################################################################

repair_network() {

    log_info "Verifying network connectivity..."

    if remote_exec ping -c1 8.8.8.8 >/dev/null 2>&1
    then
        log_success "Internet connectivity available."
        return 0
    fi

    log_warning "Internet unavailable."

    log_info "Restarting NetworkManager..."

    remote_exec sudo systemctl restart NetworkManager || true

    sleep 3

    if remote_exec ping -c1 8.8.8.8 >/dev/null 2>&1
    then
        log_success "Network restored."
        return 0
    fi

    log_error "Unable to restore network."

    return 1

}

###############################################################################
# Python
###############################################################################

repair_python() {

    log_info "Checking Python installation..."

    if remote_exec python3 --version >/dev/null 2>&1
    then
        log_success "Python already installed."
        return 0
    fi

    log_warning "Python not found."

    log_info "Installing Python..."

    remote_exec sudo apt install -y \
        python3 \
        python3-pip \
        python3-venv

    if remote_exec python3 --version >/dev/null 2>&1
    then
        log_success "Python installed."
        return 0
    fi

    log_error "Python installation failed."

    return 1

}

###############################################################################
# Python Virtual Environment
###############################################################################

repair_virtual_environment() {

    log_info "Checking virtual environment..."

    if target_exec test -d "${VENV_DIRECTORY}"
    then
        log_success "Virtual environment exists."
        return 0
    fi

    log_warning "Virtual environment missing."

    target_exec "${PYTHON_BINARY}" -m venv "${VENV_DIRECTORY}"

    if target_exec test -d "${VENV_DIRECTORY}"
    then
        log_success "Virtual environment created."
        return 0
    fi

    log_error "Unable to create virtual environment."

    return 1

}

###############################################################################
# Bluetooth
###############################################################################

repair_bluetooth() {

    log_info "Checking Bluetooth service..."

    if remote_exec systemctl is-active bluetooth >/dev/null 2>&1
    then

        if remote_exec bluetoothctl list >/dev/null 2>&1
        then
            log_success "Bluetooth operational."
            return 0
        fi

    fi

    log_warning "Bluetooth requires repair."

    remote_exec sudo systemctl enable bluetooth || true

    remote_exec sudo systemctl restart bluetooth || true

    sleep 2

    if remote_exec bluetoothctl list >/dev/null 2>&1
    then
        log_success "Bluetooth repaired."
        return 0
    fi

    log_error "Bluetooth repair failed."

    return 1

}

###############################################################################
# Package Manager
###############################################################################

repair_package_manager() {

    log_info "Checking APT..."

    if remote_exec sudo apt update >/dev/null 2>&1
    then
        log_success "APT working correctly."
        return 0
    fi

    log_warning "APT update failed."

    log_info "Cleaning package cache..."

    remote_exec sudo apt clean || true

    remote_exec sudo rm -rf /var/lib/apt/lists/* || true

    log_info "Retrying APT update..."

    if remote_exec sudo apt update >/dev/null 2>&1
    then
        log_success "APT repaired."
        return 0
    fi

    log_error "APT still failing."

    return 1

}

###############################################################################
# Systemd
###############################################################################

repair_systemd() {

    log_info "Reloading systemd..."

    remote_exec sudo systemctl daemon-reload

    log_success "Systemd reloaded."

    return 0

}

###############################################################################
# Services
###############################################################################

repair_services() {

    log_info "Restarting TinQa service..."

    remote_exec sudo systemctl restart tinqa.service || true

    sleep 2

    if remote_exec systemctl is-active tinqa.service >/dev/null 2>&1
    then
        log_success "TinQa service running."
        return 0
    fi

    log_warning "TinQa service not running."

    return 1

}

###############################################################################
# File Permissions
###############################################################################

repair_permissions() {

    log_info "Repairing ownership..."

    remote_exec sudo chown -R tinqa:tinqa /opt/tinqa || true

    remote_exec sudo chmod -R 755 /opt/tinqa || true

    log_success "Permissions repaired."

    return 0

}

###############################################################################
# Disk
###############################################################################

repair_disk() {

    log_info "Checking available disk space..."

    local available

    available="$(
        remote_exec \
            df --output=avail / \
            | tail -1
    )"

    available="${available// /}"

    if [[ "${available}" -gt 500000 ]]
    then
        log_success "Disk space sufficient."
        return 0
    fi

    log_warning "Low disk space detected."

    remote_exec sudo apt clean || true

    remote_exec sudo journalctl --vacuum-time=7d || true

    return 0

}

###############################################################################
# Application
###############################################################################

repair_application() {

    log_info "Checking TinQa installation..."

    if remote_exec test -f /opt/tinqa/main.py
    then
        log_success "Application files present."
        return 0
    fi

    log_error "Application files missing."

    return 1

}

###############################################################################
# Full Self-Healing
###############################################################################

repair_everything() {

    repair_execute "Network" repair_network

    repair_execute "Package Manager" repair_package_manager

    repair_execute "Python" repair_python

    repair_execute "Virtual Environment" repair_virtual_environment

    repair_execute "Bluetooth" repair_bluetooth

    repair_execute "Systemd" repair_systemd

    repair_execute "Services" repair_services

    repair_execute "Permissions" repair_permissions

    repair_execute "Disk" repair_disk

    repair_execute "Application" repair_application

}

###############################################################################
# Public API
###############################################################################

export -f repair_execute
export -f repair_network
export -f repair_python
export -f repair_virtual_environment
export -f repair_bluetooth
export -f repair_package_manager
export -f repair_systemd
export -f repair_services
export -f repair_permissions
export -f repair_disk
export -f repair_application
export -f repair_everything