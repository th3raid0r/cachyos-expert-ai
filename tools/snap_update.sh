#!/usr/bin/env bash
set -e

# @describe Update/refresh snaps using snap refresh
# @option --package* <PACKAGE>       Package name(s) to refresh (optional, refreshes all if none specified)
# @option --channel <CHANNEL>        Switch to specific channel (stable, candidate, beta, edge)
# @flag --list                       Show available updates without installing

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if snap is installed
    if ! command -v snap &> /dev/null; then
        echo "Error: snap is not installed on this system" >> "$LLM_OUTPUT"
    fi

    local snap_args="refresh"
    local packages=("${argc_package[@]}")

    # Build snap arguments based on flags
    if [[ -n "${argc_channel}" ]]; then
        snap_args+=" --channel ${argc_channel}"
    fi

    if [[ "${argc_list}" == "1" ]]; then
        snap_args+=" --list"
    fi

    # Execute snap command
    if [[ ${#packages[@]} -eq 0 ]]; then
        # No specific packages specified, refresh all snaps
        if sudo snap ${snap_args} 2>&1 >> "$LLM_OUTPUT"; then
            echo "Refresh completed successfully" >> "$LLM_OUTPUT"
        else
            echo "Refresh failed" >> "$LLM_OUTPUT"
        fi
    else
        # Refresh specific packages
        if sudo snap ${snap_args} "${packages[@]}" 2>&1 >> "$LLM_OUTPUT"; then
            echo "Refresh completed successfully" >> "$LLM_OUTPUT"
        else
            echo "Refresh failed" >> "$LLM_OUTPUT"
        fi
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
