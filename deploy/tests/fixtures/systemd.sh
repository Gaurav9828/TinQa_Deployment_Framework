#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : systemd.sh
# Version     : 1.0.0
#
# Description :
# Creates a fake systemd environment inside the sandbox.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Directories
###############################################################################

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SANDBOX_DIR="${TEST_DIR}/sandbox"

SYSTEMD_DIR="${SANDBOX_DIR}/etc/systemd/system"

###############################################################################
# Create Directory Structure
###############################################################################

create_systemd_directory() {

    mkdir -p \
        "${SYSTEMD_DIR}" \
        "${SANDBOX_DIR}/run/systemd/system"

}

###############################################################################
# Fake TinQa Service
###############################################################################

create_tinqa_service() {

cat > "${SYSTEMD_DIR}/tinqa.service" <<EOF
[Unit]
Description=TinQa Service
After=network.target bluetooth.target

[Service]
Type=simple
User=pi
WorkingDirectory=/opt/tinqa
ExecStart=/opt/tinqa/venv/bin/python /opt/tinqa/app/main.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

}

###############################################################################
# Fake Service Status
###############################################################################

create_service_status() {

cat > "${SANDBOX_DIR}/service.status" <<EOF
inactive
EOF

}

###############################################################################
# Start Service
###############################################################################

start_service() {

    echo "active" > "${SANDBOX_DIR}/service.status"

}

###############################################################################
# Stop Service
###############################################################################

stop_service() {

    echo "inactive" > "${SANDBOX_DIR}/service.status"

}

###############################################################################
# Restart Service
###############################################################################

restart_service() {

    stop_service

    start_service

}

###############################################################################
# Service State
###############################################################################

service_state() {

    cat "${SANDBOX_DIR}/service.status"

}

###############################################################################
# Is Service Active
###############################################################################

service_is_active() {

    [[ "$(service_state)" == "active" ]]

}

###############################################################################
# Is Service Inactive
###############################################################################

service_is_inactive() {

    [[ "$(service_state)" == "inactive" ]]

}

###############################################################################
# Initialize
###############################################################################

initialize_systemd() {

    create_systemd_directory

    create_tinqa_service

    create_service_status

}

###############################################################################
# Public API
###############################################################################

export -f \
create_systemd_directory \
create_tinqa_service \
create_service_status \
start_service \
stop_service \
restart_service \
service_state \
service_is_active \
service_is_inactive \
initialize_systemd