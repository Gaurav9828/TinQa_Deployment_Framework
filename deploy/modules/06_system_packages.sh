#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : 06_system_packages.sh
# Version     : 1.0.0
#
# Description :
# Installs and validates required system packages.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Directories
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEPLOY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

###############################################################################
# Dependencies
###############################################################################

source "${DEPLOY_ROOT}/core/logger.sh"

source "${DEPLOY_ROOT}/config/packages.conf"

###############################################################################
# Update Repository
###############################################################################

update_package_repository() {

    log_info "Updating APT repository..."

    if ! sudo apt-get update
    then

        repair_execute \
            "Package Manager" \
            repair_package_manager

        sudo apt-get update

    fi

    log_success "Repository updated."

}

###############################################################################
# Upgrade Existing Packages
###############################################################################

upgrade_system_packages() {

    log_info "Upgrading installed packages..."

    sudo DEBIAN_FRONTEND=noninteractive \
        apt-get upgrade -y

    log_success "System packages upgraded."

}

###############################################################################
# Install Required Packages
###############################################################################

all_packages_installed() {

    local package

    for package in "${APT_REQUIRED_PACKAGES[@]}"
    do
        dpkg -s "${package}" >/dev/null 2>&1 || return 1
    done

    return 0

}

install_required_packages() {
    
    if all_packages_installed
    then
        log_info "All required packages already installed."

        return 0
    fi

    log_info "Installing required packages..."

    if ! sudo \
        DEBIAN_FRONTEND=noninteractive \
        apt-get install -y \
        "${APT_REQUIRED_PACKAGES[@]}"
    then

        repair_execute \
            "Package Manager" \
            repair_package_manager

        sudo \
            DEBIAN_FRONTEND=noninteractive \
            apt-get install -y \
            "${APT_REQUIRED_PACKAGES[@]}"

    fi

    log_success "Required packages installed."

}

###############################################################################
# Verify Installed Packages
###############################################################################

verify_required_packages() {

    log_info "Verifying installed packages..."

    local failed=0

    local package

    for package in "${APT_REQUIRED_PACKAGES[@]}"
    do

        if dpkg -s "${package}" >/dev/null 2>&1
        then

            log_success "Verified : ${package}"

        else

            log_error "Missing : ${package}"

            failed=1

        fi

    done

    if (( failed == 0 ))
    then

        inspect_set packages_ok yes

    else

        inspect_set packages_ok no

    fi

    return "${failed}"

}

###############################################################################
# Remove Unused Packages
###############################################################################

cleanup_packages() {

    log_info "Removing unused packages..."

    sudo apt-get autoremove -y

    sudo apt-get autoclean -y

    log_success "Package cleanup completed."

}

###############################################################################
# Package Summary
###############################################################################

package_summary() {

    inspect_set package_count "${#APT_REQUIRED_PACKAGES[@]}"

    log_info "Installed package count : ${#APT_REQUIRED_PACKAGES[@]}"

}

###############################################################################
# Main
###############################################################################

run_06_system_packages() {

    section "Module 06 - System Packages"

    update_package_repository

    upgrade_system_packages

    install_required_packages

    verify_required_packages

    cleanup_packages

    package_summary

    log_success "System package installation completed."

}

###############################################################################
# Public API
###############################################################################

export -f \
    run_06_system_packages