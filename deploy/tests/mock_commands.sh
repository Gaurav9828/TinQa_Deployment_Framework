#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : mock_commands.sh
# Version     : 2.0.0
#
# Description :
# Mock Linux commands used by the Fake Raspberry Pi.
#
###############################################################################

set -Eeuo pipefail

: "${MOCK_VERBOSE:=1}"
#
# FAKE_PI_ROOT is initialized later by fake_pi.sh
#

mock_initialize() {

    : "${FAKE_PI_ROOT:?FAKE_PI_ROOT not set}"

    MOCK_SYSTEMD_DIR="${FAKE_PI_ROOT}/etc/systemd/system"
    MOCK_SUDOERS_DIR="${FAKE_PI_ROOT}/etc/sudoers.d"
    MOCK_BLUETOOTH_DIR="${FAKE_PI_ROOT}/var/lib/bluetooth"

    export MOCK_SYSTEMD_DIR
    export MOCK_SUDOERS_DIR
    export MOCK_BLUETOOTH_DIR
}


###############################################################################
# Logger
###############################################################################

mock_log() {

    [[ "${MOCK_VERBOSE}" == "1" ]] || return 0

    printf "[MOCK] %s\n" "$*"
}

###############################################################################
# Generic Success
###############################################################################

mock_success() {

    mock_log "$*"

    return 0
}

###############################################################################
# Generic Failure
###############################################################################

mock_failure() {

    mock_log "$*"

    return 1
}

###############################################################################
# cp
###############################################################################

cp() {

    mock_log "cp $*"

    local src="${@: -2:1}"
    local dst="${@: -1}"

    #
    # Redirect absolute Raspberry Pi paths
    #
    if [[ "${dst}" == /* ]]
    then
        dst="${FAKE_PI_ROOT}${dst}"
    fi

    command mkdir -p "$(dirname "${dst}")"

    command cp "$src" "$dst"
}

###############################################################################
# systemctl
###############################################################################

systemctl() {

    local command="${1:-}"

    shift

    # Skip options like --quiet
    while [[ "${1:-}" == -* ]]; do
        shift
    done

    local service="${1:-}"
    service="${service%.service}"

    local service_file="${FAKE_PI_ROOT}/etc/systemd/system/${service}.service"
    local running_file="${FAKE_PI_ROOT}/var/run/${service}.running"

    case "${command}" in

        list-unit-files)

            if [[ -f "${service_file}" ]]; then
                printf "%s.service enabled\n" "${service}"
            fi
            return 0
            ;;

        daemon-reload)

            mock_log "systemctl daemon-reload"
            return 0
            ;;

        enable)

            touch "${service_file}"

            mock_log "systemctl enable ${service}.service"

            return 0
            ;;

        disable)

            rm -f "${service_file}"

            mock_log "systemctl disable ${service}.service"

            return 0
            ;;

        is-enabled)

            [[ -f "${service_file}" ]]

            return $?
            ;;

        start)

            mkdir -p "${FAKE_PI_ROOT}/var/run"

            touch "${FAKE_PI_ROOT}/var/run/${service}.running"

            mock_log "systemctl start ${service}.service"

            return 0
            ;;

        stop)

            rm -f "${FAKE_PI_ROOT}/var/run/${service}.running"

            mock_log "systemctl stop ${service}.service"

            return 0
            ;;

        restart)

            mkdir -p "${FAKE_PI_ROOT}/var/run"

            touch "${FAKE_PI_ROOT}/var/run/${service}.running"

            mock_log "systemctl restart ${service}.service"

            return 0
            ;;

        is-active)

            [[ -f "${FAKE_PI_ROOT}/var/run/${service}.running" ]]

            return $?
            ;;

        status)

            if [[ -f "${FAKE_PI_ROOT}/var/run/${service}.running" ]]; then
                cat <<EOF
● ${service}.service - Fake Service
     Loaded: loaded (${service_file}; enabled)
     Active: active (running)
EOF
            else
                cat <<EOF
● ${service}.service - Fake Service
     Loaded: loaded (${service_file}; enabled)
     Active: inactive (dead)
EOF
            fi

            return 0
            ;;

        *)

            mock_log "systemctl $*"

            return 0
            ;;

    esac
}

###############################################################################
# bluetoothctl
###############################################################################

bluetoothctl() {

    case "${1:-}" in

        list)

            cat <<EOF
Controller 00:11:22:33:44:55 hci0 [default]
EOF
            ;;

        show)

            cat <<EOF
Controller 00:11:22:33:44:55
Powered: yes
Discoverable: yes
Pairable: yes
EOF
            ;;

        *)

            mock_log "bluetoothctl $*"
            ;;

    esac

    return 0
}

###############################################################################
# python3
###############################################################################

python3() {

    mock_log "python3 $*"

    if [[ "$1" == "-m" && "$2" == "venv" ]]
    then
        local venv="$3"

        mkdir -p "${venv}/bin"

        #
        # activate
        #
        cat > "${venv}/bin/activate" <<EOF
#!/usr/bin/env bash
export VIRTUAL_ENV="${venv}"
export PATH="${venv}/bin:\$PATH"
deactivate() { :; }
EOF

        #
        # python
        #
        cat > "${venv}/bin/python" <<'EOF'
#!/usr/bin/env bash
echo "[MOCK] python $*"
exit 0
EOF

        #
        # pip
        #
        cat > "${venv}/bin/pip" <<'EOF'
#!/usr/bin/env bash
echo "[MOCK] pip $*"
exit 0
EOF

        chmod +x "${venv}/bin/activate"
        chmod +x "${venv}/bin/python"
        chmod +x "${venv}/bin/pip"

        return 0
    fi

    return 0
}

python() {

    if [[ "${1:-}" == "--version" ]]
    then
        echo "Python 3.11.9"
        return 0
    fi

    mock_log "python $*"
}

###############################################################################
# pip
###############################################################################

pip3() {

    mock_log "pip3 $*"
    return 0
}

pip() {

    mock_log "pip $*"

    return 0

}

###############################################################################
# apt
###############################################################################

apt() {

    if [[ "${1:-}" == "--version" ]]
    then
        echo "apt 2.8.3"

        return 0
    fi

    mock_log "apt $*"

    return 0
}

###############################################################################
# Apt-get
###############################################################################

apt-get() {

    [[ "${MOCK_APT_FAIL:-0}" == "1" ]] && \
        mock_failure "apt-get failed"

    mock_success "apt-get $*"

}

###############################################################################
# Apt-cache
###############################################################################

apt-cache() {

    mock_success "apt-cache $*"

}

###############################################################################
# DPKG
###############################################################################

dpkg() {

    if [[ "$1" == "-s" ]]
    then
        return 0
    fi

    mock_success "dpkg $*"

}

###############################################################################
# git
###############################################################################

git() {

    mock_log "git $*"
    return 0
}

###############################################################################
# rsync
###############################################################################

rsync() {

    [[ "${MOCK_RSYNC_FAIL:-0}" == "1" ]] && {
        mock_failure "rsync failed"
        return 1
    }

    mock_log "rsync $*"

    local src="${@: -2:1}"
    local dst="${@: -1}"

    command mkdir -p "${dst}"

    command cp -a "${src}/." "${dst}/"
    
}

###############################################################################
# service
###############################################################################

service() {

    mock_log "service $*"
    return 0
}

###############################################################################
# chown
###############################################################################

chown() {

    mock_log "chown $*"
    return 0
}

###############################################################################
# sudo
###############################################################################

sudo() {

    # Skip environment variable assignments
    while [[ "$1" == *=* ]]; do
        export "$1"
        shift
    done

    "$@"
}

###############################################################################
# ping
###############################################################################

ping() {

    mock_log "ping $*"
    return 0
}

###############################################################################
# timedatectl
###############################################################################

timedatectl() {

    cat <<EOF
Local time: Mon Jul 06 12:00:00 IST
Universal time: Mon Jul 06 06:30:00 UTC
RTC time: Mon Jul 06 06:30:00
Time zone: Asia/Kolkata
System clock synchronized: yes
NTP service: active
RTC in local TZ: no
EOF
}

###############################################################################
# ip
###############################################################################

ip() {

    cat <<EOF
2: eth0: <UP>
    inet 192.168.1.100/24
EOF
}

###############################################################################
# hostname
###############################################################################

hostname() {

    case "${1:-}" in

        -s)
            echo "raspberrypi"
            ;;

        -f)
            echo "raspberrypi.local"
            ;;

        *)
            echo "raspberrypi"
            ;;

    esac
}

###############################################################################
# uname
###############################################################################

uname() {

    case "${1:-}" in

        -r)
            echo "6.6.20-v8+"
            ;;

        -m)
            echo "aarch64"
            ;;

        *)
            echo "Linux"
            ;;

    esac
}

###############################################################################
# df
###############################################################################

df() {

    cat <<EOF
Filesystem     1M-blocks Used Available Use% Mounted on
/dev/root          30000 5000     25000  17% /
EOF
}

###############################################################################
# free
###############################################################################

free() {

    cat <<EOF
              total        used        free
Mem:        4048576     1200000     2848576
EOF
}

###############################################################################
# lsblk
###############################################################################

lsblk() {

    cat <<EOF
NAME        SIZE TYPE MOUNTPOINT
mmcblk0    29.7G disk
└─mmcblk0p2 29.2G part /
EOF
}

###############################################################################
# journalctl
###############################################################################

journalctl() {

    local log="${FAKE_PI_ROOT}/var/log/tinqa.log"

    [[ -f "${log}" ]] && cat "${log}"

    return 0
}

###############################################################################
# chmod
###############################################################################

chmod() {

    mock_log "chmod $*"

    return 0
}

###############################################################################
# pgrep
###############################################################################

pgrep() {

    mock_log "pgrep $*"

    if [[ "${MOCK_PGREP_FAIL:-0}" == "1" ]]
    then
        return 1
    fi

    echo "1234"

    return 0
}

dmesg() {

cat <<EOF
[    0.000000] Linux version 6.6.20-v8+
[    1.000000] Bluetooth: Core ver 2.22
[    2.000000] Bluetooth: HCI device initialized
EOF

}

###############################################################################
# ssh
###############################################################################

ssh() {

    mock_log "ssh $*"

    #
    # Skip ssh options
    #
    while [[ "$1" == -* ]]
    do
        shift

        #
        # Skip option argument if needed
        #
        case "$1" in
            -p|-i|-o)
                shift
                ;;
        esac
    done

    #
    # Skip hostname/user
    #
    shift

    #
    # Execute remaining command locally
    #
    "$@"
}

###############################################################################
# scp
###############################################################################

scp() {

    mock_log "scp $*"

    return 0
}

###############################################################################
# sshpass
###############################################################################

sshpass() {

    shift

    "$@"
}

###############################################################################
# Export
###############################################################################

export -f \
mock_initialize \
mock_log \
mock_success \
mock_failure \
cp \
chmod \
systemctl \
bluetoothctl \
python3 \
python \
pip3 \
pip \
apt \
apt-get \
apt-cache \
dpkg \
git \
rsync \
service \
sudo \
chown \
ping \
timedatectl \
ip \
hostname \
uname \
df \
free \
lsblk \
journalctl \
pgrep \
dmesg \
ssh \
scp \
sshpass