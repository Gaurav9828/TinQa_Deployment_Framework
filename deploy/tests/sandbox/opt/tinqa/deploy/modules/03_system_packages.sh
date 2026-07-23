#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 03 - System Package Installation
###############################################################################

set -Eeuo pipefail

install_system_packages() {

    module_begin "Installing System Packages"

    set_error "$E400" "Unable to update package index"

    run "Updating APT Repository" \
        remote_exec_safe \
        "sudo apt update"

    set_error "$E401" "Unable to install required packages"

    run "Installing Required Packages" \
        remote_exec_safe \
        "
        sudo apt install -y \
            python3 \
            python3-dev \
            python3-venv \
            python3-pip \
            build-essential \
            pkg-config \
            git \
            bluez \
            libbluetooth-dev \
            libdbus-1-dev \
            python3-dbus \
            libglib2.0-dev \
            libgirepository1.0-dev \
            network-manager \
            libopenblas-dev
        "

    log_info "Verifying Installed Packages"

    local packages=(
        python3
        python3-dev
        python3-venv
        python3-pip
        build-essential
        bluez
        network-manager
        libopenblas-dev
        python3-dbus
    )

    local missing=0

    for package in "${packages[@]}"; do

        if package_installed "$package"; then
            log_success "$package"
        else
            log_error "$package"
            ((missing++))
        fi

    done

    if (( missing > 0 )); then

        set_error "$E401" \
            "${missing} required package(s) missing."

        return 1

    fi

    log_info "Collecting System Information"

    log_info "OS          : $(remote_os)"
    log_info "Hostname    : $(remote_hostname)"
    log_info "Python      : $(remote_python_version)"
    log_info "Uptime      : $(remote_uptime)"

    module_end

}