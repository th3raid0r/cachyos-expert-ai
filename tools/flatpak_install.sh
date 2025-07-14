#!/usr/bin/env bash
set -e

# @describe Install packages using flatpak install
# @option --package+ <PACKAGE>       Package name(s) to install (required, can specify multiple)
# @flag --user                       Install for current user only (default is system-wide)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        echo "Error: flatpak is not installed on this system" >> "$LLM_OUTPUT"
        exit 1
    fi

    local flatpak_args="install --noninteractive --assumeyes"
    local packages=("${argc_package[@]}")

    # Check if packages were specified
    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "Error: At least one package must be specified" >> "$LLM_OUTPUT"
        exit 1
    fi

    # Build flatpak arguments based on flags
    if [[ "${argc_user}" == "1" ]]; then
        flatpak_args+=" --user"
    fi

    # Execute flatpak command
    if flatpak ${flatpak_args} "${packages[@]}" 2>&1 >> "$LLM_OUTPUT"; then
        echo "Installation completed successfully" >> "$LLM_OUTPUT"
    else
        echo "Installation failed" >> "$LLM_OUTPUT"
        exit 1
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
