#!/usr/bin/env bash
set -e

# @describe Search the ArchWiki using MediaWiki API to find Arch Linux documentation.
# Use this when you need specific information about Arch Linux packages, configuration, or troubleshooting.

# @option --query! The search query for ArchWiki.
# @option --limit=10 Maximum number of search results to return.

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    # URL encode the query parameter
    encoded_query=$(printf '%s' "$argc_query" | jq -sRr @uri)

    # Make the API request to ArchWiki
    response=$(curl -fsSL -G "https://wiki.archlinux.org/api.php" \
        -d "action=query" \
        -d "list=search" \
        -d "srsearch=$encoded_query" \
        -d "format=json" \
        -d "srlimit=$argc_limit" \
        -d "srprop=snippet|titlesnippet|size|timestamp" \
        --user-agent "ArchWiki Search Tool/1.0")

    # Extract and format search results
    echo "$response" | jq -r '
        .query.search |
        if length == 0 then
            "No ArchWiki results found for: " + "'"$argc_query"'"
        else
            map(
                "**" + .title + "**\n" +
                "https://wiki.archlinux.org/title/" + (.title | @uri) + "\n" +
                (.snippet // .titlesnippet // "No snippet available") + "\n" +
                "Size: " + (.size | tostring) + " bytes\n"
            ) |
            join("\n")
        end
    ' >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
