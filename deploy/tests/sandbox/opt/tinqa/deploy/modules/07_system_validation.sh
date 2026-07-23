#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 07 - System Validation
###############################################################################

set -Eeuo pipefail

validate_system() {

    module_begin "System Validation"

    local warnings=0
    local failures=0

    ###########################################################################
    # SSH
    ###########################################################################

    if check_ssh; then
        log_success "SSH Connectivity"
    else
        log_error "SSH Connectivity"
        ((failures++))
    fi

    ###########################################################################
    # Project Directory
    ###########################################################################

    if remote_directory_exists "${REMOTE_PROJECT_DIR}"; then
        log_success "Project Directory"
    else
        log_error "Project Directory"
        ((failures++))
    fi

    ###########################################################################
    # Virtual Environment
    ###########################################################################

    if remote_directory_exists "${REMOTE_VENV}"; then
        log_success "Virtual Environment"
    else
        log_error "Virtual Environment"
        ((failures++))
    fi

    ###########################################################################
    # Python
    ###########################################################################

    if remote_command_exists python3; then
        log_success "Python"
    else
        log_error "Python"
        ((failures++))
    fi

    ###########################################################################
    # Pip
    ###########################################################################

    if remote_file_exists "${REMOTE_VENV}/bin/pip"; then
        log_success "Pip"
    else
        log_error "Pip"
        ((failures++))
    fi

    ###########################################################################
    # Disk Space
    ###########################################################################

    local disk

    disk=$(remote_exec "df -h / | awk 'NR==2 {print \$5}' | tr -d '%'")

    if (( disk < 90 )); then
        log_success "Disk Usage (${disk}%)"
    else
        log_warning "Disk Usage (${disk}%)"
        ((warnings++))
    fi

    ###########################################################################
    # Memory
    ###########################################################################

    local mem

    mem=$(remote_exec "free -m | awk '/Mem:/ {print \$7}'")

    if (( mem > 100 )); then
        log_success "Available Memory (${mem} MB)"
    else
        log_warning "Low Memory (${mem} MB)"
        ((warnings++))
    fi

    ###########################################################################
    # CPU Temperature
    ###########################################################################

    if remote_file_exists "/sys/class/thermal/thermal_zone0/temp"; then

        local temp

        temp=$(remote_exec "cat /sys/class/thermal/thermal_zone0/temp")

        temp=$((temp/1000))

        if (( temp < 75 )); then
            log_success "CPU Temperature (${temp}°C)"
        elif (( temp < 85 )); then
            log_warning "CPU Temperature (${temp}°C)"
            ((warnings++))
        else
            log_error "CPU Temperature (${temp}°C)"
            ((failures++))
        fi

    fi

    ###########################################################################
    # OpenBLAS
    ###########################################################################

    if remote_exec "ldconfig -p | grep libopenblas.so >/dev/null"; then
        log_success "OpenBLAS"
    else
        log_error "OpenBLAS"
        ((failures++))
    fi

    ###########################################################################
    # Network Manager
    ###########################################################################

    if service_status NetworkManager >/dev/null 2>&1; then
        log_success "NetworkManager"
    else
        log_warning "NetworkManager"
        ((warnings++))
    fi

    ###########################################################################
    # Bluetooth
    ###########################################################################

    if [[ "$(service_status bluetooth)" == "active" ]]; then
        log_success "Bluetooth"
    else
        log_error "Bluetooth"
        ((failures++))
    fi

    ###########################################################################
    # Python Import Test
    ###########################################################################

    if remote_exec "
        ${REMOTE_VENV}/bin/python - <<'EOF'
import fastapi
import uvicorn
import numpy
import serial
import PIL
import requests
import bleak
print('OK')
EOF
" >/dev/null; then
        log_success "Python Imports"
    else
        log_error "Python Imports"
        ((failures++))
    fi

    ###########################################################################
    # Summary
    ###########################################################################

    log_section "Validation Summary"

    log_plain "Warnings : ${warnings}"
    log_plain "Failures : ${failures}"

    if (( failures > 0 )); then
        set_error "$E700" "System validation failed."
        return 1
    fi

    module_end

}