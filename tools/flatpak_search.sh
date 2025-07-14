#!/usr/bin/env bash
set -e

# @describe Search for packages in Flatpak repositories using flatpak search
# @option --query* <QUERY>           Search term(s) (can specify multiple)
# @flag --app                        Search for applications only
# @flag --runtime                    Search for runtimes only

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if flatpak is installed
    if ! command -v flatpak &> /dev/null; then
        echo "Error: flatpak is not installed on this system" >> "$LLM_OUTPUT"
        exit 0
    fi

    local flatpak_args="search"
    local queries=("${argc_query[@]}")

    # Build flatpak arguments based on flags
    if [[ "${argc_app}" == "1" ]]; then
        flatpak_args+=" --app"
    fi

    if [[ "${argc_runtime}" == "1" ]]; then
        flatpak_args+=" --runtime"
    fi

    # Force no pager
    export PAGER=cat

    # Execute flatpak command
    if [[ ${#queries[@]} -eq 0 ]]; then
        # No search terms specified, show all available packages
        flatpak ${flatpak_args} 2>/dev/null >> "$LLM_OUTPUT" || {
            echo "Error: Failed to search flatpaks" >> "$LLM_OUTPUT"
            exit 0
        }
    else
        # Search with specific terms
        for query in "${queries[@]}"; do
            flatpak ${flatpak_args} "${query}" 2>/dev/null >> "$LLM_OUTPUT" || true
        done
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
