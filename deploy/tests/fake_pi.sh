#!/usr/bin/env bash
###############################################################################
#
# Fake Raspberry Pi
#
###############################################################################

set -Eeuo pipefail

FAKE_PI_ROOT="${SANDBOX_ROOT}/fake_pi"

initialize_fake_pi() {

    rm -rf "${FAKE_PI_ROOT}"

    ###########################################################################
    # Linux Root
    ###########################################################################

    mkdir -p "${FAKE_PI_ROOT}"

    ###########################################################################
    # /etc
    ###########################################################################

    mkdir -p "${FAKE_PI_ROOT}/etc/systemd/system"
    mkdir -p "${FAKE_PI_ROOT}/etc/sudoers.d"
    mkdir -p "${FAKE_PI_ROOT}/etc/bluetooth"
    mkdir -p "${FAKE_PI_ROOT}/etc/dbus-1"
    mkdir -p "${FAKE_PI_ROOT}/etc/network"

    ###########################################################################
    # /opt
    ###########################################################################

    mkdir -p "${FAKE_PI_ROOT}/opt/tinqa"

    ###########################################################################
    # Existing Installation
    ###########################################################################

    mkdir -p "${FAKE_PI_ROOT}/opt/tinqa/logs"
    mkdir -p "${FAKE_PI_ROOT}/opt/tinqa/backup"
    mkdir -p "${FAKE_PI_ROOT}/opt/tinqa/temp"

    ###########################################################################
    # /home
    ###########################################################################

    mkdir -p "${FAKE_PI_ROOT}/home/pi"

    ###########################################################################
    # /usr
    ###########################################################################

    mkdir -p "${FAKE_PI_ROOT}/usr/bin"
    mkdir -p "${FAKE_PI_ROOT}/usr/lib"
    mkdir -p "${FAKE_PI_ROOT}/usr/local/bin"

    ###########################################################################
    # /var
    ###########################################################################

    mkdir -p "${FAKE_PI_ROOT}/var/lib/bluetooth"
    mkdir -p "${FAKE_PI_ROOT}/var/log"
    mkdir -p "${FAKE_PI_ROOT}/var/run"
    mkdir -p "${FAKE_PI_ROOT}/var/tmp"

    ###########################################################################
    # Other Linux Directories
    ###########################################################################

    mkdir -p "${FAKE_PI_ROOT}/tmp"
    mkdir -p "${FAKE_PI_ROOT}/dev"
    mkdir -p "${FAKE_PI_ROOT}/proc"
    mkdir -p "${FAKE_PI_ROOT}/sys"

    ###########################################################################
    # Fake Running Services
    ###########################################################################

    mkdir -p "${FAKE_PI_ROOT}/var/run"

    touch "${FAKE_PI_ROOT}/var/run/bluetooth.running"
    touch "${FAKE_PI_ROOT}/var/run/NetworkManager.running"
    touch "${FAKE_PI_ROOT}/var/run/tinqa.running"

    ###########################################################################
    # Raspberry Pi OS Information
    ###########################################################################

    cat > "${FAKE_PI_ROOT}/etc/os-release" <<EOF
NAME="Raspberry Pi OS"
VERSION="Bookworm"
ID=raspbian
VERSION_ID="12"
PRETTY_NAME="Raspberry Pi OS Bookworm"
EOF

    ###########################################################################
    # Existing TinQa Service
    ###########################################################################

    cat > "${FAKE_PI_ROOT}/etc/systemd/system/tinqa.service" <<EOF
[Unit]
Description=TinQa Weather Sync System
After=network.target bluetooth.target

[Service]
Type=simple
User=pi
WorkingDirectory=/opt/tinqa
ExecStart=/opt/tinqa/venv/bin/python -m app.main
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    ###########################################################################
    # Fake Bluetooth Controller
    ###########################################################################

    mkdir -p \
        "${FAKE_PI_ROOT}/var/lib/bluetooth/00:11:22:33:44:55/cache"

    touch \
        "${FAKE_PI_ROOT}/var/lib/bluetooth/00:11:22:33:44:55/settings"

    ###########################################################################
    # Fake Deployment Logs
    ###########################################################################

    touch "${FAKE_PI_ROOT}/var/log/syslog"
    touch "${FAKE_PI_ROOT}/var/log/messages"

    ###########################################################################
    # Fake Runtime Files
    ###########################################################################

    touch "${FAKE_PI_ROOT}/var/run/tinqa.pid"

    export FAKE_PI_ROOT
}