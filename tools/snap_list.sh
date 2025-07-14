#!/usr/bin/env bash
set -e

# @describe List installed snaps using snap list
# @option --package* <PACKAGE>       Package name(s) to check (can specify multiple, optional)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if snap is installed
    if ! command -v snap &> /dev/null; then
        echo "Error: snap is not installed on this system" >> "$LLM_OUTPUT"
    fi

    local snap_args="list"
    local packages=("${argc_package[@]}")

    # Force no pager
    export PAGER=cat

    # Execute snap command
    if [[ ${#packages[@]} -eq 0 ]]; then
        # No specific packages specified, list all installed snaps
        snap ${snap_args} 2>/dev/null >> "$LLM_OUTPUT" || {
            echo "Error: Failed to list installed snaps" >> "$LLM_OUTPUT"
        }
    else
        # Check specific packages
        for package in "${packages[@]}"; do
            snap ${snap_args} "${package}" 2>/dev/null >> "$LLM_OUTPUT" || true
        done
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
