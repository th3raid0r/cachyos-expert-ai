#!/usr/bin/env bash
set -e

# @describe Update system packages using pacman -Syu
# @flag --refresh                    Force refresh of package databases before update
# @option --ignore* <PACKAGE>        Ignore specified packages during update

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local pacman_args="-Syu --noconfirm --noprogressbar"
    local ignore_packages=("${argc_ignore[@]}")

    if [[ "${argc_refresh}" == "1" ]]; then
        # Add extra y for forced refresh
        pacman_args="${pacman_args/Syu/Syyu}"
    fi

    # Add ignore packages if specified
    for package in "${ignore_packages[@]}"; do
        pacman_args+=" --ignore ${package}"
    done

    # Execute pacman command
    if sudo pacman ${pacman_args} 2>&1 >> "$LLM_OUTPUT"; then
        echo "System update completed successfully" >> "$LLM_OUTPUT"
    else
        echo "System update failed" >> "$LLM_OUTPUT"
        exit 1
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
