#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 08 - Systemd Service
###############################################################################

set -Eeuo pipefail

install_systemd_service() {

    module_begin "Installing Systemd Service"

    ###########################################################################
    # Create Service File
    ###########################################################################

    local service_file="/tmp/${SERVICE_NAME}"

    cat > "${service_file}" <<EOF
[Unit]
Description=TinQa Weather Sync System
After=network.target bluetooth.service NetworkManager.service
Wants=network.target bluetooth.service

[Service]

Type=simple

User=${PI_USER}
WorkingDirectory=${REMOTE_PROJECT_DIR}

Environment=PYTHONUNBUFFERED=1
Environment=PYTHONPATH=${REMOTE_PROJECT_DIR}

ExecStart=${REMOTE_VENV}/bin/python -m app.main

Restart=always
RestartSec=5

KillMode=process

StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    ###########################################################################
    # Validate Service File
    ###########################################################################

    run "Validating Service File" \
        systemd-analyze verify "${service_file}"

    ###########################################################################
    # Upload Service File
    ###########################################################################

    run "Uploading Service File" \
        scp \
        "${SSH_OPTIONS[@]}" \
        "${service_file}" \
        "${SSH_TARGET}:/tmp/${SERVICE_NAME}"

    ###########################################################################
    # Install Service
    ###########################################################################

    run "Installing Service" \
        remote_exec_safe \
        "
        sudo mv /tmp/${SERVICE_NAME} /etc/systemd/system/${SERVICE_NAME}
        "

    ###########################################################################
    # Reload Systemd
    ###########################################################################

    run "Reloading Systemd" \
        remote_exec_safe \
        "
        sudo systemctl daemon-reload
        "

    ###########################################################################
    # Enable Service
    ###########################################################################

    run "Enabling Service" \
        remote_exec_safe \
        "
        sudo systemctl enable ${SERVICE_NAME}
        "

    ###########################################################################
    # Start Service
    ###########################################################################

    run "Starting Service" \
        remote_exec_safe \
        "
        sudo systemctl restart ${SERVICE_NAME}
        "

    sleep "${SERVICE_STARTUP_WAIT}"

    ###########################################################################
    # Verify Service
    ###########################################################################

    if [[ "$(service_status "${SERVICE_NAME}")" == "active" ]]; then

        log_success "Service Running"

    else

        log_error "Service Failed"

        log_section "Last 50 Journal Entries"

        remote_exec \
            "journalctl -u ${SERVICE_NAME} -n 50 --no-pager"

        set_error "$E801" "Service failed to start"

        return 1

    fi

    ###########################################################################
    # Service Status
    ###########################################################################

    log_info "Service Status"

    remote_exec \
        "systemctl status ${SERVICE_NAME} --no-pager"

    ###########################################################################
    # Cleanup
    ###########################################################################

    rm -f "${service_file}"

    module_end

}