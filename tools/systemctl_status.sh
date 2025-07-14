#!/usr/bin/env bash
set -e

# @describe Check status of systemd units using systemctl status
# @option --unit* <UNIT>             Service unit name(s) to check (can specify multiple, optional)
# @flag --user                       Check user units only (default is system-wide)
# @option --lines <LINES>            Number of journal lines to show

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local systemctl_args="status --no-pager --full"
    local units=("${argc_unit[@]}")

    # Build systemctl arguments based on flags
    if [[ "${argc_user}" == "1" ]]; then
        systemctl_args+=" --user"
    fi

    if [[ -n "${argc_lines}" ]]; then
        systemctl_args+=" --lines=${argc_lines}"
    fi

    # Execute systemctl command
    if [[ ${#units[@]} -eq 0 ]]; then
        # No specific units specified, show overall system status
        systemctl ${systemctl_args} 2>&1 >> "$LLM_OUTPUT" || {
            echo "Error: Failed to get system status" >> "$LLM_OUTPUT"
            exit 1
        }
    else
        # Check specific units
        for unit in "${units[@]}"; do
            systemctl ${systemctl_args} "${unit}" 2>&1 >> "$LLM_OUTPUT" || true
        done
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
