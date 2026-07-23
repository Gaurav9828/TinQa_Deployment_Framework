#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 09 - Runtime Health Check
###############################################################################

set -Eeuo pipefail

health_check() {

    module_begin "Application Health Check"

    local warnings=0
    local failures=0

###############################################################################
# Service Status
###############################################################################

    if [[ "$(service_status "${SERVICE_NAME}")" == "active" ]]; then
        log_success "Systemd Service"
    else
        log_error "Systemd Service"
        ((failures++))
    fi

###############################################################################
# Process Running
###############################################################################

    if remote_exec "pgrep -f 'app.main' >/dev/null"; then
        log_success "Python Process"
    else
        log_error "Python Process"
        ((failures++))
    fi

###############################################################################
# CPU Usage
###############################################################################

    cpu=$(remote_exec "ps -C python -o %cpu= | head -1 | awk '{print int(\$1)}'")

    if [[ -z "$cpu" ]]; then
        cpu=0
    fi

    if (( cpu < 80 )); then
        log_success "CPU Usage (${cpu}%)"
    else
        log_warning "CPU Usage (${cpu}%)"
        ((warnings++))
    fi

###############################################################################
# Memory Usage
###############################################################################

    memory=$(remote_exec "ps -C python -o rss= | head -1")

    if [[ -z "$memory" ]]; then
        memory=0
    fi

    memory=$((memory/1024))

    if (( memory < 400 )); then
        log_success "Memory Usage (${memory} MB)"
    else
        log_warning "Memory Usage (${memory} MB)"
        ((warnings++))
    fi

###############################################################################
# Bluetooth
###############################################################################

    if [[ "$(service_status bluetooth)" == "active" ]]; then
        log_success "Bluetooth Service"
    else
        log_error "Bluetooth Service"
        ((failures++))
    fi

###############################################################################
# D-Bus
###############################################################################

    if remote_exec "busctl tree org.bluez >/dev/null"; then
        log_success "BlueZ DBus"
    else
        log_error "BlueZ DBus"
        ((failures++))
    fi

###############################################################################
# BLE Adapter
###############################################################################

    if remote_exec "bluetoothctl show | grep Powered | grep yes >/dev/null"; then
        log_success "BLE Adapter"
    else
        log_warning "BLE Adapter"
        ((warnings++))
    fi

###############################################################################
# Network
###############################################################################

    if remote_exec "ping -c1 8.8.8.8 >/dev/null"; then
        log_success "Internet Connectivity"
    else
        log_warning "Internet Connectivity"
        ((warnings++))
    fi

###############################################################################
# Serial Devices
###############################################################################

    serial_ports=$(remote_exec "ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | wc -l")

    log_info "Serial Devices : ${serial_ports}"

###############################################################################
# API Check
###############################################################################

    if remote_exec "curl -fs http://127.0.0.1:8000/docs >/dev/null"; then
        log_success "FastAPI Server"
    else
        log_warning "FastAPI Server"
        ((warnings++))
    fi

###############################################################################
# Journal Errors
###############################################################################

    journal_errors=$(remote_exec \
        "journalctl -u ${SERVICE_NAME} --since '-2 min' | grep -i error | wc -l")

    if (( journal_errors == 0 )); then
        log_success "Journal Errors"
    else
        log_warning "Journal Errors (${journal_errors})"
        ((warnings++))
    fi

###############################################################################
# Summary
###############################################################################

    log_section "Health Summary"

    log_plain "Warnings : ${warnings}"
    log_plain "Failures : ${failures}"

    if (( failures > 0 )); then

        set_error "$E704" \
        "Application health check failed."

        return 1

    fi

    module_end

}