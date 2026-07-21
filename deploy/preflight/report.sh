#!/usr/bin/env bash

set -Eeuo pipefail

print_report() {

    while IFS='=' read -r key value
    do

        printf "%-20s %s\n" "$key" "$value"

    done

}