#!/usr/bin/env bash
set -e

# @describe Update/upgrade flatpaks using flatpak update
# @option --package* <PACKAGE>       Package name(s) to update (optional, updates all if none specified)
# @flag --user                       Update user installations only (default is system-wide)
# @flag --app                        Update applications only
# @flag --runtime                    Update runtimes only

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        echo "Error: flatpak is not installed on this system" >> "$LLM_OUTPUT"
        exit 0
    fi

    local flatpak_args="update --noninteractive --assumeyes"
    local packages=("${argc_package[@]}")

    # Build flatpak arguments based on flags
    if [[ "${argc_user}" == "1" ]]; then
        flatpak_args+=" --user"
    fi

    if [[ "${argc_app}" == "1" ]]; then
        flatpak_args+=" --app"
    fi

    if [[ "${argc_runtime}" == "1" ]]; then
        flatpak_args+=" --runtime"
    fi

    # Execute flatpak command
    if [[ ${#packages[@]} -eq 0 ]]; then
        # No specific packages specified, update all flatpaks
        if flatpak ${flatpak_args} 2>&1 >> "$LLM_OUTPUT"; then
            echo "Update completed successfully" >> "$LLM_OUTPUT"
        else
            echo "Update failed" >> "$LLM_OUTPUT"
            exit 0
        fi
    else
        # Update specific packages
        if flatpak ${flatpak_args} "${packages[@]}" 2>&1 >> "$LLM_OUTPUT"; then
            echo "Update completed successfully" >> "$LLM_OUTPUT"
        else
            echo "Update failed" >> "$LLM_OUTPUT"
            exit 0
        fi
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
