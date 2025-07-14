#!/usr/bin/env bash
set -e

# @describe Update system packages using yay -Syu (includes AUR packages)
# @flag --refresh                    Force refresh of package databases before update
# @flag --aur-only                   Only update AUR packages
# @flag --repo-only                  Only update official repository packages
# @flag --devel                      Update AUR development packages
# @option --ignore* <PACKAGE>        Ignore specified packages during update

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local yay_args="-Syu --noconfirm --noprogressbar"
    local ignore_packages=("${argc_ignore[@]}")

    # Build yay arguments based on flags
    if [[ "${argc_refresh}" == "1" ]]; then
        # Add extra y for forced refresh
        yay_args="${yay_args/Syu/Syyu}"
    fi

    if [[ "${argc_aur_only}" == "1" ]]; then
        yay_args+=" --aur"
    fi

    if [[ "${argc_repo_only}" == "1" ]]; then
        yay_args+=" --repo"
    fi

    if [[ "${argc_devel}" == "1" ]]; then
        yay_args+=" --devel"
    fi

    # Add ignore packages if specified
    for package in "${ignore_packages[@]}"; do
        yay_args+=" --ignore ${package}"
    done

    # Execute yay command (no sudo needed, yay handles privilege escalation)
    if yay ${yay_args} 2>&1 >> "$LLM_OUTPUT"; then
        echo "System update completed successfully" >> "$LLM_OUTPUT"
    else
        echo "System update failed" >> "$LLM_OUTPUT"
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
