#!/usr/bin/env bash
set -e

# @describe Check if packages are installed using pacman -Q
# @option --package* <PACKAGE>       Package name(s) to check (can specify multiple)
# @flag --explicit                   Only show explicitly installed packages
# @flag --deps                       Only show packages installed as dependencies

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local pacman_args="-Q"
    local packages=("${argc_package[@]}")

    # Build pacman arguments based on flags
    if [[ "${argc_explicit}" == "1" ]]; then
        pacman_args+="e"
    fi

    if [[ "${argc_deps}" == "1" ]]; then
        pacman_args+="d"
    fi

    # Force no pager
    export PAGER=cat

    if [[ ${#packages[@]} -eq 0 ]]; then
        # No specific packages specified, list all installed packages
        pacman ${pacman_args} 2>/dev/null >> "$LLM_OUTPUT" || {
            echo "Error: Failed to query installed packages" >> "$LLM_OUTPUT"
            exit 1
        }
    else
        # Check specific packages
        for package in "${packages[@]}"; do
            pacman ${pacman_args} "${package}" 2>/dev/null >> "$LLM_OUTPUT" || true
        done
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
