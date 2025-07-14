#!/usr/bin/env bash
set -e

# @describe Remove packages using pacman -R
# @option --package+ <PACKAGE>       Package name(s) to remove (required, can specify multiple)
# @flag --recursive                  Remove packages and their dependencies
# @flag --nosave                     Remove configuration files as well

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local pacman_args="-R --noconfirm --noprogressbar"
    local packages=("${argc_package[@]}")

    # Check if packages were specified
    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "Error: At least one package must be specified" >> "$LLM_OUTPUT"
        exit 1
    fi

    # Build pacman arguments based on flags
    if [[ "${argc_recursive}" == "1" ]]; then
        pacman_args+=" --recursive"
    fi

    if [[ "${argc_nosave}" == "1" ]]; then
        pacman_args+=" --nosave"
    fi

    # Execute pacman command
    if sudo pacman ${pacman_args} "${packages[@]}" 2>&1 >> "$LLM_OUTPUT"; then
        echo "Removal completed successfully" >> "$LLM_OUTPUT"
    else
        echo "Removal failed" >> "$LLM_OUTPUT"
        exit 1
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
