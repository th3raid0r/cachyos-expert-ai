#!/usr/bin/env bash
set -e

# @describe List systemd units, timers, sockets, and services using systemctl
# @flag --all                        Show all units including inactive ones
# @flag --failed                     Show only failed units
# @option --state <STATE>            Filter by unit state (active, inactive, failed, loaded, etc.)
# @option --type <TYPE>              Filter by unit type (service, timer, socket, target, mount, etc.)
# @flag --user                       List user units only (default is system-wide)
# @flag --unit-files                 List unit files instead of units
# @flag --enabled                    Show only enabled unit files (use with --unit-files)
# @flag --disabled                   Show only disabled unit files (use with --unit-files)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local systemctl_args=""
    local list_command="list-units"

    # Determine the base command
    if [[ "${argc_unit_files}" == "1" ]]; then
        list_command="list-unit-files"
    fi

    systemctl_args="${list_command} --no-pager --full"

    # Build systemctl arguments based on flags
    if [[ "${argc_user}" == "1" ]]; then
        systemctl_args+=" --user"
    fi

    if [[ "${argc_system}" == "1" ]]; then
        systemctl_args+=" --system"
    fi

    if [[ "${argc_all}" == "1" ]]; then
        systemctl_args+=" --all"
    fi

    if [[ "${argc_failed}" == "1" ]]; then
        systemctl_args+=" --failed"
    fi

    if [[ -n "${argc_state}" ]]; then
        systemctl_args+=" --state=${argc_state}"
    fi

    if [[ -n "${argc_type}" ]]; then
        systemctl_args+=" --type=${argc_type}"
    fi


    # Unit files specific flags (only apply if --unit-files is set)
    if [[ "${argc_unit_files}" == "1" ]]; then
        # Override any previous --state setting for unit-files specific states
        if [[ "${argc_enabled}" == "1" ]]; then
            systemctl_args="${systemctl_args/--state=*/}"
            systemctl_args+=" --state=enabled"
        elif [[ "${argc_disabled}" == "1" ]]; then
            systemctl_args="${systemctl_args/--state=*/}"
            systemctl_args+=" --state=disabled"
        fi
    fi

    # Execute systemctl command
    if systemctl ${systemctl_args} 2>&1 >> "$LLM_OUTPUT"; then
        echo "Listing completed successfully" >> "$LLM_OUTPUT"
    else
        echo "Listing failed" >> "$LLM_OUTPUT"
        exit 1
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
