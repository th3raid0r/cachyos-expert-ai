#!/usr/bin/env bash
set -e

# @describe List installed flatpaks using flatpak list
# @option --package* <PACKAGE>       Package name(s) to check (can specify multiple, optional)
# @flag --user                       List user installations only (default is system-wide)
# @flag --app                        List applications only
# @flag --runtime                    List runtimes only

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        echo "Error: flatpak is not installed on this system" >> "$LLM_OUTPUT"
        exit 0
    fi

    local flatpak_args="list"
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

    # Force no pager
    export PAGER=cat

    # Execute flatpak command
    if [[ ${#packages[@]} -eq 0 ]]; then
        # No specific packages specified, list all installed flatpaks
        flatpak ${flatpak_args} 2>/dev/null >> "$LLM_OUTPUT" || {
            echo "Error: Failed to list installed flatpaks" >> "$LLM_OUTPUT"
            exit 0
        }
    else
        # Check specific packages
        for package in "${packages[@]}"; do
            flatpak ${flatpak_args} | grep -i "${package}" >> "$LLM_OUTPUT" || true
        done
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
