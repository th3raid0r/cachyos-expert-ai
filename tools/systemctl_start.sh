#!/usr/bin/env bash
set -e

# @describe Start systemd units using systemctl start
# @option --unit+ <UNIT>             Service unit name(s) to start (required, can specify multiple)
# @flag --user                       Start for current user only (default is system-wide)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local systemctl_args="start --no-pager"
    local units=("${argc_unit[@]}")

    # Check if units were specified
    if [[ ${#units[@]} -eq 0 ]]; then
        echo "Error: At least one unit must be specified" >> "$LLM_OUTPUT"
        exit 1
    fi

    # Build systemctl arguments based on flags
    if [[ "${argc_user}" == "1" ]]; then
        systemctl_args+=" --user"
    fi

    # Execute systemctl command
    if sudo systemctl ${systemctl_args} "${units[@]}" 2>&1 >> "$LLM_OUTPUT"; then
        echo "Units started successfully: ${units[*]}" >> "$LLM_OUTPUT"
    else
        echo "Failed to start units: ${units[*]}" >> "$LLM_OUTPUT"
        exit 1
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
