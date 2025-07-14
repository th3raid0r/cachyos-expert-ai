#!/usr/bin/env bash
set -e

# @describe Install packages using yay -S (supports both official repos and AUR)
# @option --package+ <PACKAGE>       Package name(s) to install (required, can specify multiple)
# @flag --needed                     Only install packages that are not already installed
# @flag --as-deps                    Install packages as dependencies
# @flag --aur-only                   Only search AUR packages
# @flag --repo-only                  Only search official repository packages

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local yay_args="-S --noconfirm --noprogressbar"
    local packages=("${argc_package[@]}")

    # Check if packages were specified
    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "Error: At least one package must be specified" >> "$LLM_OUTPUT"
    fi

    # Build yay arguments based on flags
    if [[ "${argc_needed}" == "1" ]]; then
        yay_args+=" --needed"
    fi

    if [[ "${argc_as_deps}" == "1" ]]; then
        yay_args+=" --asdeps"
    fi

    if [[ "${argc_aur_only}" == "1" ]]; then
        yay_args+=" --aur"
    fi

    if [[ "${argc_repo_only}" == "1" ]]; then
        yay_args+=" --repo"
    fi

    # Execute yay command (no sudo needed, yay handles privilege escalation)
    if yay ${yay_args} "${packages[@]}" 2>&1 >> "$LLM_OUTPUT"; then
        echo "Installation completed successfully" >> "$LLM_OUTPUT"
    else
        echo "Installation failed" >> "$LLM_OUTPUT"
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
