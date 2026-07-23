#!/usr/bin/env bash
###############################################################################
#
# Module 03 - Operating System Update
#
###############################################################################

set -Eeuo pipefail

###############################################################################

run_03_os_update() {

    section "Module 03 - Operating System Update"

    ####################################################
    # Internet
    ####################################################

    log_info "Checking internet connectivity..."

    if ! target_exec ping -c1 8.8.8.8 >/dev/null 2>&1
    then

        log_warning "Internet unavailable."

        repair_execute \
            "Network" \
            repair_network

        if ! target_exec ping -c1 8.8.8.8 >/dev/null 2>&1
        then
            log_error "Internet connectivity could not be restored."

            return 1
        fi

    fi

    ####################################################
    # Package Index
    ####################################################

    log_info "Updating package index..."

    if ! target_exec sudo apt update
    then

        repair_execute \
            "Package Manager" \
            repair_package_manager

        target_exec sudo apt update

    fi

    ####################################################
    # Upgrade Packages
    ####################################################

    log_info "Upgrading operating system..."

    target_exec \
        sudo DEBIAN_FRONTEND=noninteractive \
        apt full-upgrade -y

    ####################################################
    # Broken Packages
    ####################################################

    log_info "Repairing broken packages..."

    target_exec \
        sudo apt --fix-broken install -y

    ####################################################
    # Remove Unused Packages
    ####################################################

    log_info "Removing unused packages..."

    target_exec \
        sudo apt autoremove -y

    ####################################################
    # Clean Cache
    ####################################################

    log_info "Cleaning package cache..."

    target_exec \
        sudo apt clean

    ####################################################
    # Reboot Required
    ####################################################

    if target_exec test -f /var/run/reboot-required
    then

        inspect_set reboot_required yes

        log_warning "Operating system reboot will be required."

    else

        inspect_set reboot_required no

    fi

    ####################################################
    # Summary
    ####################################################

    log_success "Operating system update completed."

}

###############################################################################

export -f run_03_os_update