#!/usr/bin/env bash

###############################################################################
# TinQa Deployment Framework
# Module 05 - Python Package Installation
###############################################################################

set -Eeuo pipefail

install_python_packages() {

    module_begin "Installing Python Packages"

    ###########################################################################
    # Verify requirements.txt
    ###########################################################################

    set_error "$E501" "requirements.txt not found"

    run "Checking requirements.txt" \
        remote_file_exists \
        "${REMOTE_PROJECT_DIR}/${REQUIREMENTS_FILE}"

    ###########################################################################
    # Install Requirements
    ###########################################################################

    local package_count=0
    local success_count=0
    local failed_packages=()

    while IFS= read -r line || [[ -n "$line" ]]; do

        #######################################################################
        # Ignore comments and blank lines
        #######################################################################

        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^# ]] && continue

        package_count=$((package_count+1))

        local package="$line"

        local package_name="${package%%=*}"

        log_info "Installing ${package}"

        local start_time
        start_time=$(date +%s)

        if remote_exec_safe "
            source '${REMOTE_VENV}/bin/activate'
            pip install --no-cache-dir '${package}'
        "; then

            local finish_time
            finish_time=$(date +%s)

            local elapsed=$((finish_time-start_time))

            log_success "${package_name} (${elapsed}s)"

            success_count=$((success_count+1))

        else

            log_error "${package_name}"

            failed_packages+=("${package}")

        fi

    done < "${LOCAL_PROJECT_DIR}/${REQUIREMENTS_FILE}"

    ###########################################################################
    # Check Result
    ###########################################################################

    if [[ ${#failed_packages[@]} -gt 0 ]]; then

        printf "\n"

        log_error "Failed Packages"

        for package in "${failed_packages[@]}"; do

            printf "   • %s\n" "$package"

        done

        set_error "$E501" "Python dependency installation failed"

        return 1

    fi

    ###########################################################################
    # Validate Imports
    ###########################################################################

    log_info "Validating Installed Packages"

    while IFS= read -r line || [[ -n "$line" ]]; do

        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^# ]] && continue

        local package="$line"

        local module="${package%%=*}"

        module="${module//-/_}"

        case "$module" in

            Pillow)

                module="PIL"

                ;;

        esac

        if remote_exec_safe "
            source '${REMOTE_VENV}/bin/activate'
            python -c 'import ${module}'
        "; then

            log_success "${module}"

        else

            log_error "${module}"

        fi

    done < "${LOCAL_PROJECT_DIR}/${REQUIREMENTS_FILE}"

    ###########################################################################
    # Package Summary
    ###########################################################################

    printf "\n"

    log_section "Python Package Summary"

    log_plain "Packages Found      : ${package_count}"
    log_plain "Installed           : ${success_count}"
    log_plain "Failed              : ${#failed_packages[@]}"

    module_end

}