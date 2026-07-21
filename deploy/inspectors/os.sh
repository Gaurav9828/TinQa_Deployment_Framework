#!/usr/bin/env bash

set -Eeuo pipefail

inspect_os() {

    echo "Operating System"

    if [[ -f /etc/os-release ]]
    then
        source /etc/os-release

        echo "Name        : ${PRETTY_NAME}"
        echo "Version     : ${VERSION_ID}"
        echo "Codename    : ${VERSION_CODENAME:-Unknown}"
    else
        echo "Unable to determine OS."
    fi

}

export -f inspect_os