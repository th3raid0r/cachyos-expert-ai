#!/usr/bin/env bash
set -e

# @describe Install packages using pacman -S
# @option --package+ <PACKAGE>       Package name(s) to install (required, can specify multiple)
# @flag --needed                     Only install packages that are not already installed
# @flag --as-deps                    Install packages as dependencies

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local pacman_args="-S --noconfirm --noprogressbar"
    local packages=("${argc_package[@]}")

    # Check if packages were specified
    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "Error: At least one package must be specified" >> "$LLM_OUTPUT"
        exit 1
    fi

    # Build pacman arguments based on flags
    if [[ "${argc_needed}" == "true" ]]; then
        pacman_args+=" --needed"
    fi

    if [[ "${argc_as_deps}" == "true" ]]; then
        pacman_args+=" --asdeps"
    fi

    # Execute pacman command
    echo "Executing: sudo pacman ${pacman_args} ${packages[*]}" >> "$LLM_OUTPUT"

    if sudo pacman ${pacman_args} "${packages[@]}" 2>&1 >> "$LLM_OUTPUT"; then
        echo "Installation completed successfully" >> "$LLM_OUTPUT"
    else
        echo "Installation failed or was cancelled" >> "$LLM_OUTPUT"
        exit 1
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
