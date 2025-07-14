#!/usr/bin/env bash
set -e

# @describe Perform a web search using Kagi API to get up-to-date information or additional context.
# Use this when you need current information or feel a search could provide a better answer.

# @option --query! The query to search for.
# @option --limit=10 Maximum number of search results to return.

# @env KAGI_API_KEY! The Kagi API key
# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # URL encode the query parameter
    encoded_query=$(printf '%s' "$argc_query" | jq -sRr @uri)

    # Make the API request to Kagi
    response=$(curl -fsSL -G "https://kagi.com/api/v0/search" \
        -H "Authorization: Bot $KAGI_API_KEY" \
        -d "q=$encoded_query" \
        -d "limit=$argc_limit")

    # Extract and format search results
    echo "$response" | jq -r '
        map(select(.t == 0)) |
        if length == 0 then
            "No search results found."
        else
            map("**" + .title + "**\n" + .url + "\n" + (.snippet // "No snippet available") + "\n") |
            join("\n")
        end
    ' >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
