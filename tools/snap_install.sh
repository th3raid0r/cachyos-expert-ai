#!/usr/bin/env bash
set -e

# @describe Install packages using snap install
# @option --package+ <PACKAGE>       Package name(s) to install (required, can specify multiple)
# @flag --classic                    Install snap with classic confinement
# @option --channel <CHANNEL>        Install from specific channel (stable, candidate, beta, edge)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if snap is installed
    if ! command -v snap &> /dev/null; then
        echo "Error: snap is not installed on this system" >> "$LLM_OUTPUT"
        exit 0
    fi

    local snap_args="install"
    local packages=("${argc_package[@]}")

    # Check if packages were specified
    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "Error: At least one package must be specified" >> "$LLM_OUTPUT"
        exit 0
    fi

    # Build snap arguments based on flags
    if [[ "${argc_classic}" == "1" ]]; then
        snap_args+=" --classic"
    fi

    if [[ -n "${argc_channel}" ]]; then
        snap_args+=" --channel ${argc_channel}"
    fi

    # Execute snap command
    if sudo snap ${snap_args} "${packages[@]}" 2>&1 >> "$LLM_OUTPUT"; then
        echo "Installation completed successfully" >> "$LLM_OUTPUT"
    else
        echo "Installation failed" >> "$LLM_OUTPUT"
        exit 0
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
