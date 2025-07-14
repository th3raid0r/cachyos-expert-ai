#!/usr/bin/env bash
set -e

# @describe Check for Arch Linux update notices and mark them as read if any are unread

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    if newscheck check | grep -q "no unread" 2>&1 >> "$LLM_OUTPUT"; then
        echo "All notices are up to date" >> "$LLM_OUTPUT"
    else
        if sudo newscheck read --all 2>&1 >> "$LLM_OUTPUT"; then
            echo "All notices marked as read" >> "$LLM_OUTPUT"
        else
            echo "Failed to mark notices as read" >> "$LLM_OUTPUT"
            exit 1
        fi
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
