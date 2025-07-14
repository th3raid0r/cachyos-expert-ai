#!/usr/bin/env bash
set -e

# @describe Check for Arch Linux update notices and mark them as read if any are unread

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    if newscheck check | grep -q "no unread" 2>&1 >> "$LLM_OUTPUT"; then
        echo "All notices are up to date" >> "$LLM_OUTPUT"
    else
        output=$(sudo newscheck list --unread 2>&1)
        ## Example output
        # 0: linux-firmware >= 20250613.12fe085f-5 upgrade requires manual intervention Sat, 21 Jun 2025 16:09:08 -0700
        # 1: Plasma 6.4.0 will need manual intervention if you are on X11      Fri, 20 Jun 2025 00:08:17 -0700
        # 2: Transition to the new WoW64 wine and wine-staging                 Mon, 16 Jun 2025 09:22:01 -0700
        exit_code=$?
        echo "$output" >> "$LLM_OUTPUT"
        ## Parse the output so we know how many entries there are.
        num_entries=$(echo "$output" | wc -l)
        num_entries=$(($num_entries - 1))
        ## Max entries always 10, use newscheck read $i in order to read.
        for i in {0..9}; do
            notice=$(newscheck read $i)
            echo "Notice $i: $notice" >> "$LLM_OUTPUT"
        done

    fi
}

eval "$(argc --argc-eval "$0" "$@")"
