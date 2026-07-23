#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 06 - Bluetooth Configuration
###############################################################################

set -Eeuo pipefail

configure_bluetooth() {

    module_begin "Bluetooth Configuration"

    ###########################################################################
    # Enable Bluetooth Service
    ###########################################################################

    set_error "$E600" "Unable to enable Bluetooth"

    run "Enabling Bluetooth Service" \
        remote_exec_safe \
        "sudo systemctl enable bluetooth"

    run "Starting Bluetooth Service" \
        remote_exec_safe \
        "sudo systemctl restart bluetooth"

    sleep 3

    ###########################################################################
    # Verify Service
    ###########################################################################

    if [[ "$(service_status bluetooth)" == "active" ]]; then
        log_success "Bluetooth Service Active"
    else
        log_error "Bluetooth Service Inactive"
        return 1
    fi

    ###########################################################################
    # Verify Adapter
    ###########################################################################

    run "Checking Bluetooth Adapter" \
        remote_exec_safe \
        "bluetoothctl list | grep hci"

    ###########################################################################
    # Power Adapter
    ###########################################################################

    run "Powering Bluetooth Adapter" \
        remote_exec_safe \
        "
        bluetoothctl <<EOF
power on
quit
EOF
        "

    ###########################################################################
    # Enable Agent
    ###########################################################################

    run "Registering Bluetooth Agent" \
        remote_exec_safe \
        "
        bluetoothctl <<EOF
agent on
default-agent
quit
EOF
        "

    ###########################################################################
    # Pairable
    ###########################################################################

    run "Setting Pairable Mode" \
        remote_exec_safe \
        "
        bluetoothctl <<EOF
pairable on
quit
EOF
        "

    ###########################################################################
    # Discoverable
    ###########################################################################

    run "Setting Discoverable Mode" \
        remote_exec_safe \
        "
        bluetoothctl <<EOF
discoverable on
quit
EOF
        "

    ###########################################################################
    # BlueZ Version
    ###########################################################################

    log_info "BlueZ Version"

    remote_exec \
        "bluetoothctl --version"

    ###########################################################################
    # Controller Information
    ###########################################################################

    log_info "Bluetooth Controller"

    remote_exec \
        "bluetoothctl show"

    ###########################################################################
    # Validate DBus
    ###########################################################################

    run "Checking DBus Communication" \
        remote_exec_safe \
        "
        busctl tree org.bluez >/dev/null
        "

    ###########################################################################
    # Validate Scan
    ###########################################################################

    run "Testing BLE Scan Capability" \
        remote_exec_safe \
        "
        timeout 5 bluetoothctl scan on >/dev/null 2>&1 || true
        bluetoothctl scan off >/dev/null 2>&1
        "

    ###########################################################################
    # Validate RFKill
    ###########################################################################

    run "Checking RFKill Status" \
        remote_exec_safe \
        "
        rfkill list bluetooth
        "

    ###########################################################################
    # Finished
    ###########################################################################

    module_end

}