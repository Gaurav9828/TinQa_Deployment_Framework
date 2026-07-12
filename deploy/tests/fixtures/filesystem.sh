#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : filesystem.sh
# Version     : 1.0.0
#
# Description :
# Creates a fake TinQa filesystem inside the sandbox.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Directories
###############################################################################

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SANDBOX_DIR="${TEST_DIR}/sandbox"

###############################################################################
# Fake Project Structure
###############################################################################

create_project_tree() {

    mkdir -p \
        "${SANDBOX_DIR}/opt/tinqa" \
        "${SANDBOX_DIR}/opt/tinqa/app" \
        "${SANDBOX_DIR}/opt/tinqa/config" \
        "${SANDBOX_DIR}/opt/tinqa/logs" \
        "${SANDBOX_DIR}/opt/tinqa/scripts" \
        "${SANDBOX_DIR}/opt/tinqa/systemd" \
        "${SANDBOX_DIR}/opt/tinqa/venv"

}

###############################################################################
# Fake Application
###############################################################################

create_application_files() {

cat > "${SANDBOX_DIR}/opt/tinqa/app/main.py" <<EOF
print("TinQa Test Application")
EOF

cat > "${SANDBOX_DIR}/opt/tinqa/requirements.txt" <<EOF
fastapi
uvicorn
pybluez
EOF

}

###############################################################################
# Fake Environment
###############################################################################

create_environment() {

cat > "${SANDBOX_DIR}/opt/tinqa/.env" <<EOF
APPLICATION_ENV=production
LOG_LEVEL=INFO
EOF

}

###############################################################################
# Fake Log Files
###############################################################################

create_logs() {

    touch "${SANDBOX_DIR}/opt/tinqa/logs/deploy.log"

    touch "${SANDBOX_DIR}/opt/tinqa/logs/application.log"

}

###############################################################################
# Fake Backup Folder
###############################################################################

create_backup_directory() {

    mkdir -p \
        "${SANDBOX_DIR}/opt/backups"

}

###############################################################################
# Initialize Filesystem
###############################################################################

initialize_filesystem() {

    create_project_tree

    create_application_files

    create_environment

    create_logs

    create_backup_directory

}

###############################################################################
# Public API
###############################################################################

export -f \
create_project_tree \
create_application_files \
create_environment \
create_logs \
create_backup_directory \
initialize_filesystem