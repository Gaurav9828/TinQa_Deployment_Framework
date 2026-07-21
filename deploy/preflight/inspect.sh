#!/usr/bin/env bash
###############################################################################
#
# Remote Raspberry Pi Inspector
#
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/../remote/ssh.sh"

inspect_pi() {

    local host="$1"

    echo
    echo "==========================================================="
    echo "Inspecting Raspberry Pi..."
    echo "==========================================================="
    echo

    ssh_exec "$host" "
echo 'HOSTNAME='$(hostname)
echo 'OS='$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')
echo 'KERNEL='$(uname -r)
echo 'ARCH='$(uname -m)
echo 'PYTHON='$(python3 --version 2>/dev/null || echo Missing)
echo 'MEMORY='$(free -m | awk '/Mem:/ {print \$2}')
echo 'DISK='$(df -h / | awk 'NR==2 {print \$4}')
echo 'BLUETOOTH='$(systemctl is-active bluetooth)
echo 'NETWORKMANAGER='$(systemctl is-active NetworkManager)
echo 'WIFI='$(nmcli -t -f WIFI general)
echo 'INTERNET='$(ping -c1 8.8.8.8 >/dev/null && echo OK || echo FAIL)
"

}