#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File : banner.sh
#
# Version : 1.0.0
#
# Terminal User Interface
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Colors
###############################################################################

readonly CLR_RESET="\033[0m"

readonly CLR_RED="\033[31m"

readonly CLR_GREEN="\033[32m"

readonly CLR_YELLOW="\033[33m"

readonly CLR_BLUE="\033[34m"

readonly CLR_MAGENTA="\033[35m"

readonly CLR_CYAN="\033[36m"

readonly CLR_WHITE="\033[97m"

readonly CLR_GRAY="\033[90m"

readonly CLR_BOLD="\033[1m"

###############################################################################
# Width
###############################################################################

readonly TERMINAL_WIDTH=80

###############################################################################
# Draw Line
###############################################################################

ui_line() {

    printf "%*s\n" "${TERMINAL_WIDTH}" "" | tr ' ' '='

}

###############################################################################
# Draw Thin Line
###############################################################################

ui_thin_line() {

    printf "%*s\n" "${TERMINAL_WIDTH}" "" | tr ' ' '-'

}

###############################################################################
# Center Text
###############################################################################

ui_center() {

    local text="$1"

    printf "%*s\n" $(( (${#text}+TERMINAL_WIDTH)/2 )) "${text}"

}

###############################################################################
# Blank Line
###############################################################################

ui_blank() {

    echo

}

###############################################################################
# Framework Banner
###############################################################################

show_banner() {

clear

echo -e "${CLR_CYAN}"

ui_line

ui_blank

ui_center "████████╗██╗███╗   ██╗ ██████╗  █████╗"
ui_center "╚══██╔══╝██║████╗  ██║██╔═══██╗██╔══██╗"
ui_center "   ██║   ██║██╔██╗ ██║██║   ██║███████║"
ui_center "   ██║   ██║██║╚██╗██║██║▄▄ ██║██╔══██║"
ui_center "   ██║   ██║██║ ╚████║╚██████╔╝██║  ██║"
ui_center "   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚══▀▀═╝ ╚═╝  ╚═╝"

ui_blank

ui_center "TinQa Deployment Framework"

ui_center "Version ${BANNER_VERSION}"

ui_blank

ui_line

echo -e "${CLR_RESET}"

}

###############################################################################
# Section Header
###############################################################################

section() {

    local title="$1"

    echo

    echo -e "${CLR_BLUE}"

    ui_thin_line

    ui_center "${title}"

    ui_thin_line

    echo -e "${CLR_RESET}"

}

###############################################################################
# Module Header
###############################################################################

module_banner() {

    local name="$1"

    local number="$2"

    echo

    echo -e "${CLR_MAGENTA}"

    printf "[MODULE %02d] %s\n" "${number}" "${name}"

    ui_thin_line

    echo -e "${CLR_RESET}"

}

###############################################################################
# Status Box
###############################################################################

status_box() {

    local title="$1"

    local value="$2"

    printf "%-30s : %s\n" "${title}" "${value}"

}

###############################################################################
# Box Drawing Characters
###############################################################################

readonly BOX_H="─"
readonly BOX_V="│"
readonly BOX_TL="┌"
readonly BOX_TR="┐"
readonly BOX_BL="└"
readonly BOX_BR="┘"
readonly BOX_L="├"
readonly BOX_R="┤"
readonly BOX_T="┬"
readonly BOX_B="┴"
readonly BOX_C="┼"

###############################################################################
# Draw Empty Box
###############################################################################

ui_box() {

    local title="$1"

    printf "%s" "${BOX_TL}"

    printf "%0.s${BOX_H}" $(seq 1 78)

    printf "%s\n" "${BOX_TR}"

    printf "${BOX_V} %-76s ${BOX_V}\n" "${title}"

    printf "%s" "${BOX_L}"

    printf "%0.s${BOX_H}" $(seq 1 78)

    printf "%s\n" "${BOX_R}"

}

###############################################################################
# Print Key/Value
###############################################################################

ui_property() {

    local key="$1"

    local value="$2"

    printf "${BOX_V} %-20s : %-53s ${BOX_V}\n" \
        "${key}" \
        "${value}"

}

###############################################################################
# Close Box
###############################################################################

ui_box_end() {

    printf "%s" "${BOX_BL}"

    printf "%0.s${BOX_H}" $(seq 1 78)

    printf "%s\n" "${BOX_BR}"

}

###############################################################################
# Deployment Summary
###############################################################################

deployment_summary() {

    ui_box "Deployment Summary"

    ui_property "Project" "${PROJECT_NAME}"

    ui_property "Framework" "${FRAMEWORK_VERSION}"

    ui_property "Status" "${DEPLOYMENT_STATUS}"

    ui_property "Modules" "${MODULE_COUNT}"

    ui_property "Steps" "${STEP_COUNT}"

    ui_property "Success" "${SUCCESS_COUNT}"

    ui_property "Warnings" "${WARNING_COUNT}"

    ui_property "Errors" "${ERROR_COUNT}"

    ui_property "Duration" "${DEPLOYMENT_DURATION}"

    ui_property "Log File" "${LOG_FILE}"

    ui_box_end

}

###############################################################################
# System Information
###############################################################################

system_summary() {

    ui_box "System Information"

    ui_property "Hostname" "$(hostname)"

    ui_property "Kernel" "$(uname -r)"

    ui_property "Architecture" "$(uname -m)"

    ui_property "User" "$(whoami)"

    ui_property "Python" "$(python3 --version 2>/dev/null)"

    ui_property "Working Dir" "$(pwd)"

    ui_box_end

}

###############################################################################
# Success Banner
###############################################################################

success_banner() {

echo

echo -e "${CLR_GREEN}"

ui_line

ui_center "✓ DEPLOYMENT COMPLETED SUCCESSFULLY"

ui_line

echo -e "${CLR_RESET}"

}

###############################################################################
# Warning Banner
###############################################################################

warning_banner() {

echo

echo -e "${CLR_YELLOW}"

ui_line

ui_center "⚠ DEPLOYMENT COMPLETED WITH WARNINGS"

ui_line

echo -e "${CLR_RESET}"

}

###############################################################################
# Error Banner
###############################################################################

error_banner() {

echo

echo -e "${CLR_RED}"

ui_line

ui_center "✗ DEPLOYMENT FAILED"

ui_line

echo -e "${CLR_RESET}"

}

###############################################################################
# Progress Bar
###############################################################################

draw_progress() {

    local current="$1"
    local total="$2"
    local title="${3:-Progress}"

    local width=40
    local percent=0
    local filled=0
    local empty=0

    if (( total > 0 )); then
        percent=$(( current * 100 / total ))
        filled=$(( current * width / total ))
    fi

    empty=$(( width - filled ))

    printf "\r%-20s [" "${title}"

    printf "%0.s#" $(seq 1 "${filled}")

    printf "%0.s-" $(seq 1 "${empty}")

    printf "] %3d%% (%d/%d)" \
        "${percent}" \
        "${current}" \
        "${total}"

    if (( current == total )); then
        printf "\n"
    fi

}

###############################################################################
# Module Progress
###############################################################################

module_progress() {

    local current="$1"
    local total="$2"
    local module="$3"

    draw_progress \
        "${current}" \
        "${total}" \
        "${module}"

}

###############################################################################
# Step Progress
###############################################################################

step_progress() {

    local current="$1"
    local total="$2"

    draw_progress \
        "${current}" \
        "${total}" \
        "Steps"

}

###############################################################################
# Spinner
###############################################################################

spinner() {

    local pid="$1"

    local delay=0.10

    local spin='-\|/'

    while kill -0 "${pid}" 2>/dev/null
    do

        for ((i=0;i<4;i++))
        do

            printf "\r[%c] Working..." "${spin:$i:1}"

            sleep "${delay}"

        done

    done

    printf "\r"

}

###############################################################################
# Deployment Finished Screen
###############################################################################

deployment_finished() {

    clear
    show_banner

    echo "ERROR_COUNT   = ${ERROR_COUNT}"
    echo "WARNING_COUNT = ${WARNING_COUNT}"

    if [[ "${ERROR_COUNT}" -gt 0 ]]; then

        error_banner

    elif [[ "${WARNING_COUNT}" -gt 0 ]]; then

        warning_banner

    else

        success_banner

    fi

    if (( ${#ERROR_MESSAGES[@]} > 0 )); then

        echo
        echo "Errors encountered:"

        printf '  • %s\n' "${ERROR_MESSAGES[@]}"

    fi

    if (( ${#WARNING_MESSAGES[@]} > 0 )); then

        echo
        echo "Warnings encountered:"

        printf '  • %s\n' "${WARNING_MESSAGES[@]}"

    fi

    echo

    deployment_summary

    echo

    system_summary

    echo

}

###############################################################################
# Goodbye Screen
###############################################################################

goodbye() {

cat <<EOF

===============================================================================

                 Thank you for using TinQa Deployment Framework

                          Deployment Session Finished

===============================================================================

EOF

}

###############################################################################
# Public API
###############################################################################

export -f \
    show_banner \
    section \
    module_banner \
    status_box \
    ui_line \
    ui_thin_line \
    ui_center \
    ui_blank \
    ui_box \
    ui_property \
    ui_box_end \
    deployment_summary \
    system_summary \
    success_banner \
    warning_banner \
    error_banner \
    draw_progress \
    module_progress \
    step_progress \
    spinner \
    deployment_finished \
    goodbye

###############################################################################
# Self Test
###############################################################################

banner_self_test() {

    command -v printf >/dev/null 2>&1 || return 1

    [[ "${TERMINAL_WIDTH}" -gt 0 ]] || return 1

    return 0

}