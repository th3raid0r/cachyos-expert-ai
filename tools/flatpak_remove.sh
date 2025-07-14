#!/usr/bin/env bash
set -e

# @describe Remove packages using flatpak uninstall
# @option --package+ <PACKAGE>       Package name(s) to remove (required, can specify multiple)
# @flag --user                       Remove from user installation (default is system-wide)
# @flag --unused                     Remove unused runtimes and extensions
# @flag --delete-data                Delete application data

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        echo "Error: flatpak is not installed on this system" >> "$LLM_OUTPUT"
        exit 0
    fi

    local flatpak_args="uninstall --noninteractive --assumeyes"
    local packages=("${argc_package[@]}")

    # Check if packages were specified
    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "Error: At least one package must be specified" >> "$LLM_OUTPUT"
        exit 0
    fi

    # Build flatpak arguments based on flags
    if [[ "${argc_user}" == "1" ]]; then
        flatpak_args+=" --user"
    fi

    if [[ "${argc_unused}" == "1" ]]; then
        flatpak_args+=" --unused"
    fi

    if [[ "${argc_delete_data}" == "1" ]]; then
        flatpak_args+=" --delete-data"
    fi

    # Execute flatpak command
    if flatpak ${flatpak_args} "${packages[@]}" 2>&1 >> "$LLM_OUTPUT"; then
        echo "Removal completed successfully" >> "$LLM_OUTPUT"
    else
        echo "Removal failed" >> "$LLM_OUTPUT"
        exit 0
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
