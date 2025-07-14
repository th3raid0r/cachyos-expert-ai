#!/usr/bin/env bash
set -e

# @describe Search for packages in Snap store using snap find
# @option --query* <QUERY>           Search term(s) (can specify multiple)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # Check if snap is installed
    if ! command -v snap &> /dev/null; then
        echo "Error: snap is not installed on this system" >> "$LLM_OUTPUT"
    fi

    local snap_args="find"
    local queries=("${argc_query[@]}")

    # Force no pager
    export PAGER=cat

    # Execute snap command
    if [[ ${#queries[@]} -eq 0 ]]; then
        # No search terms specified, show featured snaps
        snap ${snap_args} 2>/dev/null >> "$LLM_OUTPUT" || {
            echo "Error: Failed to search snaps" >> "$LLM_OUTPUT"
        }
    else
        # Search with specific terms
        for query in "${queries[@]}"; do
            snap ${snap_args} "${query}" 2>/dev/null >> "$LLM_OUTPUT" || true
        done
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
