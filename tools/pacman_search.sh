#!/usr/bin/env bash
set -e

# @describe Search for packages in repositories using pacman -Ss
# @option --query* <QUERY>           Search term(s) (can specify multiple)
# @flag --installed                  Search only installed packages (-Qs instead of -Ss)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local pacman_args="-Ss"
    local queries=("${argc_query[@]}")

    # Switch to local search if --installed flag is set
    if [[ "${argc_installed}" == "true" ]]; then
        pacman_args="-Qs"
    fi

    # Force no pager and raw output
    export PAGER=cat

    # Execute pacman command
    if [[ ${#queries[@]} -eq 0 ]]; then
        # No search terms specified, show all packages
        pacman ${pacman_args} 2>/dev/null >> "$LLM_OUTPUT" || {
            echo "Error: Failed to search packages" >> "$LLM_OUTPUT"
            exit 1
        }
    else
        # Search with specific terms
        for query in "${queries[@]}"; do
            pacman ${pacman_args} "${query}" 2>/dev/null >> "$LLM_OUTPUT" || true
        done
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
