#!/usr/bin/env bash

set -Eeuo pipefail

repair_systemd() {

    sudo systemctl daemon-reexec

    sudo systemctl daemon-reload

}

export -f repair_systemd