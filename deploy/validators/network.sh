#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : network.sh
# Version     : 1.0.0
#
# Description :
# Network validation utilities.
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

###############################################################################
# Validate Internet Connectivity
###############################################################################

validate_internet() {

    log_info "Checking Internet connectivity..."

    if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1
    then
        log_success "Internet connectivity verified."
        return 0
    fi

    log_error "Internet connectivity unavailable."

    return 1

}

###############################################################################
# Validate DNS Resolution
###############################################################################

validate_dns() {

    log_info "Checking DNS resolution..."

    if getent hosts github.com >/dev/null 2>&1
    then
        log_success "DNS resolution verified."
        return 0
    fi

    log_error "DNS resolution failed."

    return 1

}

###############################################################################
# Validate Default Gateway
###############################################################################

validate_gateway() {

    log_info "Checking default gateway..."

    if ip route | grep -q "^default"
    then
        log_success "Default gateway detected."
        return 0
    fi

    log_error "Default gateway not found."

    return 1

}

###############################################################################
# Validate Network Interface
###############################################################################

validate_interface() {

    local interface="${1}"

    log_info "Checking interface : ${interface}"

    if ip link show "${interface}" >/dev/null 2>&1
    then
        log_success "Interface exists."
        return 0
    fi

    log_error "Interface not found."

    return 1

}

###############################################################################
# Validate Interface State
###############################################################################

validate_interface_up() {

    local interface="${1}"

    log_info "Checking interface state : ${interface}"

    if ip link show "${interface}" | grep -q "state UP"
    then
        log_success "Interface is UP."
        return 0
    fi

    log_error "Interface is DOWN."

    return 1

}

###############################################################################
# Validate IP Address
###############################################################################

validate_ip_address() {

    local interface="${1}"

    log_info "Checking IP address..."

    if ip addr show "${interface}" | grep -q "inet "
    then
        log_success "IP address assigned."
        return 0
    fi

    log_error "No IP address assigned."

    return 1

}

###############################################################################
# Validate Open TCP Port
###############################################################################

validate_tcp_port() {

    local port="${1}"

    log_info "Checking TCP port : ${port}"

    if ss -ltn | awk '{print $4}' | grep -q ":${port}$"
    then
        log_success "TCP port ${port} is listening."
        return 0
    fi

    log_error "TCP port ${port} is not listening."

    return 1

}

###############################################################################
# Validate Open UDP Port
###############################################################################

validate_udp_port() {

    local port="${1}"

    log_info "Checking UDP port : ${port}"

    if ss -lun | awk '{print $5}' | grep -q ":${port}$"
    then
        log_success "UDP port ${port} is listening."
        return 0
    fi

    log_error "UDP port ${port} is not listening."

    return 1

}

###############################################################################
# Full Network Validation
###############################################################################

validate_network() {

    validate_gateway
    validate_dns
    validate_internet

}

###############################################################################
# Public API
###############################################################################

export -f \
    validate_internet \
    validate_dns \
    validate_gateway \
    validate_interface \
    validate_interface_up \
    validate_ip_address \
    validate_tcp_port \
    validate_udp_port \
    validate_network