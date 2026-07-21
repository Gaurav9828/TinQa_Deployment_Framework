#!/usr/bin/env bash
###############################################################################
#
# Retry Engine
#
###############################################################################

set -Eeuo pipefail

retry() {

    local attempts="$1"
    shift

    local delay="$1"
    shift

    local count=1

    until "$@"
    do

        if (( count >= attempts ))
        then
            return 1
        fi

        echo
        echo "[WARN] Retry ${count}/${attempts}"

        sleep "${delay}"

        ((count++))

    done

}

export -f retry