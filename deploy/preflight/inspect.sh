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
echo 'HOSTNAME='\$(hostname)
echo 'OS='\$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '\"' || uname -s)
echo 'KERNEL='\$(uname -r)
echo 'ARCH='\$(uname -m)
echo 'PYTHON='\$(python3 --version 2>/dev/null || echo Missing)
echo 'MEMORY='\$(free -m | awk '/Mem:/ {print \$2}')
echo 'DISK='\$(df -h / | awk 'NR==2 {print \$4}')
echo 'BLUETOOTH='\$(systemctl is-active bluetooth 2>/dev/null || echo unknown)
echo 'NETWORKMANAGER='\$(systemctl is-active NetworkManager 2>/dev/null || echo unknown)
echo 'WIFI='\$(nmcli -t -f WIFI general 2>/dev/null || echo unknown)
echo 'INTERNET='\$(ping -c1 8.8.8.8 >/dev/null 2>&1 && echo OK || echo FAIL)
"

}