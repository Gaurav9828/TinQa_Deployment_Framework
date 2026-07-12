#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Color & Icon Definitions
###############################################################################

set -Eeuo pipefail

###############################################################################
# Detect Terminal Color Support
###############################################################################

if [[ -t 1 ]] && [[ "${ENABLE_COLOR_OUTPUT:-true}" == "true" ]]; then
    readonly COLOR_RESET="\033[0m"

    readonly COLOR_BLACK="\033[0;30m"
    readonly COLOR_RED="\033[0;31m"
    readonly COLOR_GREEN="\033[0;32m"
    readonly COLOR_YELLOW="\033[0;33m"
    readonly COLOR_BLUE="\033[0;34m"
    readonly COLOR_MAGENTA="\033[0;35m"
    readonly COLOR_CYAN="\033[0;36m"
    readonly COLOR_WHITE="\033[0;37m"

    readonly COLOR_BOLD="\033[1m"

    readonly COLOR_BRIGHT_RED="\033[1;31m"
    readonly COLOR_BRIGHT_GREEN="\033[1;32m"
    readonly COLOR_BRIGHT_YELLOW="\033[1;33m"
    readonly COLOR_BRIGHT_BLUE="\033[1;34m"
    readonly COLOR_BRIGHT_MAGENTA="\033[1;35m"
    readonly COLOR_BRIGHT_CYAN="\033[1;36m"
    readonly COLOR_BRIGHT_WHITE="\033[1;37m"

else

    readonly COLOR_RESET=""

    readonly COLOR_BLACK=""
    readonly COLOR_RED=""
    readonly COLOR_GREEN=""
    readonly COLOR_YELLOW=""
    readonly COLOR_BLUE=""
    readonly COLOR_MAGENTA=""
    readonly COLOR_CYAN=""
    readonly COLOR_WHITE=""

    readonly COLOR_BOLD=""

    readonly COLOR_BRIGHT_RED=""
    readonly COLOR_BRIGHT_GREEN=""
    readonly COLOR_BRIGHT_YELLOW=""
    readonly COLOR_BRIGHT_BLUE=""
    readonly COLOR_BRIGHT_MAGENTA=""
    readonly COLOR_BRIGHT_CYAN=""
    readonly COLOR_BRIGHT_WHITE=""

fi

###############################################################################
# Status Icons
###############################################################################

readonly ICON_SUCCESS="✔"
readonly ICON_WARNING="⚠"
readonly ICON_ERROR="✖"
readonly ICON_INFO="ℹ"
readonly ICON_STEP="▶"
readonly ICON_CHECK="✓"
readonly ICON_CROSS="✗"
readonly ICON_BULLET="•"

###############################################################################
# Status Labels
###############################################################################

readonly STATUS_SUCCESS="${COLOR_BRIGHT_GREEN}${ICON_SUCCESS} SUCCESS${COLOR_RESET}"
readonly STATUS_WARNING="${COLOR_BRIGHT_YELLOW}${ICON_WARNING} WARNING${COLOR_RESET}"
readonly STATUS_ERROR="${COLOR_BRIGHT_RED}${ICON_ERROR} ERROR${COLOR_RESET}"
readonly STATUS_INFO="${COLOR_BRIGHT_BLUE}${ICON_INFO} INFO${COLOR_RESET}"

###############################################################################
# Helper Functions
###############################################################################

color_green() {
    printf "%b%s%b" "${COLOR_BRIGHT_GREEN}" "$1" "${COLOR_RESET}"
}

color_red() {
    printf "%b%s%b" "${COLOR_BRIGHT_RED}" "$1" "${COLOR_RESET}"
}

color_yellow() {
    printf "%b%s%b" "${COLOR_BRIGHT_YELLOW}" "$1" "${COLOR_RESET}"
}

color_blue() {
    printf "%b%s%b" "${COLOR_BRIGHT_BLUE}" "$1" "${COLOR_RESET}"
}

color_cyan() {
    printf "%b%s%b" "${COLOR_BRIGHT_CYAN}" "$1" "${COLOR_RESET}"
}

color_white() {
    printf "%b%s%b" "${COLOR_BRIGHT_WHITE}" "$1" "${COLOR_RESET}"
}

bold() {
    printf "%b%s%b" "${COLOR_BOLD}" "$1" "${COLOR_RESET}"
}

###############################################################################
# End
###############################################################################