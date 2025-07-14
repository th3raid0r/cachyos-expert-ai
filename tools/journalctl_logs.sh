#!/usr/bin/env bash
set -e

# @describe Parse and query systemd journal logs using journalctl
# @option --unit* <UNIT>             Filter logs for specific service unit(s)
# @option --since <TIME>             Show logs since specific time (e.g., "2 hours ago", "yesterday")
# @option --lines <LINES>            Number of recent log lines to show
# @option --priority <PRIORITY>      Filter by log priority (0-7 or emerg, alert, crit, err, warning, notice, info, debug)
# @flag --follow                     Follow log output (real-time)
# @flag --boot                       Show logs from current boot only
# @flag --kernel                     Show kernel messages only
# @flag --user                       Show user session logs (default is system)

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
    local journalctl_args=("--no-pager")
    local units=("${argc_unit[@]}")

    # Build journalctl arguments based on flags
    if [[ "${argc_user}" == "1" ]]; then
        journalctl_args+=("--user")
    fi

    if [[ "${argc_follow}" == "1" ]]; then
        journalctl_args+=("--follow")
        # Remove --no-pager for follow mode
        journalctl_args=("${journalctl_args[@]/--no-pager}")
    fi

    if [[ "${argc_boot}" == "1" ]]; then
        journalctl_args+=("--boot")
    fi

    if [[ "${argc_kernel}" == "1" ]]; then
        journalctl_args+=("--dmesg")
    fi

    if [[ -n "${argc_since}" ]]; then
        journalctl_args+=("--since=${argc_since}")
    fi

    if [[ -n "${argc_lines}" ]]; then
        journalctl_args+=("--lines=${argc_lines}")
    fi

    if [[ -n "${argc_priority}" ]]; then
        journalctl_args+=("--priority=${argc_priority}")
    fi

    # Add unit filters
    for unit in "${units[@]}"; do
        journalctl_args+=("--unit=${unit}")
    done

    # Execute journalctl command
    if journalctl "${journalctl_args[@]}" 2>&1 >> "$LLM_OUTPUT"; then
        if [[ "${argc_follow}" != "1" ]]; then
            echo "Journal query completed successfully" >> "$LLM_OUTPUT"
        fi
    else
        echo "Journal query failed" >> "$LLM_OUTPUT"
        exit 1
    fi
}

eval "$(argc --argc-eval "$0" "$@")"
