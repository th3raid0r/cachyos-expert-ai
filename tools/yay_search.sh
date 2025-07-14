#!/usr/bin/env bash
set -e

# @describe Search for packages in repositories and AUR using yay -Ss
# @option --query* <QUERY>           Search term(s) (can specify multiple)
# @flag --aur-only                   Search only AUR packages
# @flag --repo-only                  Search only official repository packages
# @flag --installed                  Search only installed packages (-Qs instead of -Ss)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local yay_args="-Ss"
    local queries=("${argc_query[@]}")

    # Switch to local search if --installed flag is set
    if [[ "${argc_installed}" == "true" ]]; then
        yay_args="-Qs"
    fi

    # Build yay arguments based on flags
    if [[ "${argc_aur_only}" == "1" ]]; then
        yay_args+=" --aur"
    fi

    if [[ "${argc_repo_only}" == "1" ]]; then
        yay_args+=" --repo"
    fi

    # Force no pager
    export PAGER=cat

    # Execute yay command
    if [[ ${#queries[@]} -eq 0 ]]; then
        # No search terms specified, show all packages
        yay ${yay_args} 2>/dev/null >> "$LLM_OUTPUT" || {
            echo "Error: Failed to search packages" >> "$LLM_OUTPUT"
        }
    else
        # Search with specific terms
        for query in "${queries[@]}"; do
            yay ${yay_args} "${query}" 2>/dev/null >> "$LLM_OUTPUT" || true
        done
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
