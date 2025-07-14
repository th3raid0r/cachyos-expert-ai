#!/usr/bin/env bash
set -e

# @describe Remove packages using snap remove
# @option --package+ <PACKAGE>       Package name(s) to remove (required, can specify multiple)
# @flag --purge                      Remove snap and its data completely

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if snap is installed
    if ! command -v snap &> /dev/null; then
        echo "Error: snap is not installed on this system" >> "$LLM_OUTPUT"
    fi

    local snap_args="remove"
    local packages=("${argc_package[@]}")

    # Check if packages were specified
    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "Error: At least one package must be specified" >> "$LLM_OUTPUT"
        exit 0
    fi

    # Build snap arguments based on flags
    if [[ "${argc_purge}" == "1" ]]; then
        snap_args+=" --purge"
    fi

    # Execute snap command

    if sudo snap ${snap_args} "${packages[@]}" 2>&1 >> "$LLM_OUTPUT"; then
        echo "Removal completed successfully" >> "$LLM_OUTPUT"
    else
        echo "Removal failed" >> "$LLM_OUTPUT"
        exit 0
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
