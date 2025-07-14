#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd)"
BIN_DIR="$ROOT_DIR/bin"
MCP_DIR="$ROOT_DIR/cache/__mcp__"
MCP_LOG_FILE="$MCP_DIR/mcp-bridge.log"
MCP_JSON_PATH="$ROOT_DIR/mcp.json"
FUNCTIONS_JSON_PATH="$ROOT_DIR/functions.json"
MCP_BRIDGE_PORT="${MCP_BRIDGE_PORT:-8808}"

# @cmd Start/restart the mcp bridge server
# @alias restart
start() {
    if [[ ! -f "$MCP_JSON_PATH" ]]; then
        _die "error: not found mcp.json"
    fi
    stop
    mkdir -p "$MCP_DIR"
    index_js="$ROOT_DIR/mcp/bridge/index.js"
    llm_functions_dir="$ROOT_DIR"
    if _is_win; then
        index_js="$(cygpath -w "$index_js")"
        llm_functions_dir="$(cygpath -w "$llm_functions_dir")"
    fi
    echo "Start MCP Bridge server..."
    echo "Install node dependencies..." > "$MCP_LOG_FILE"
    (cd "$ROOT_DIR/mcp/bridge" && npm install 1>/dev/null 2>> "$MCP_LOG_FILE")
    nohup node "$index_js" "$llm_functions_dir" >> "$MCP_LOG_FILE" 2>&1 &
    wait-for-server
    echo "Merge MCP tools into functions.json"
    "$0" merge-functions -S
    build-bin
}

# @cmd Stop the mcp bridge server
stop() {
    pid="$(get-server-pid)"
    if [[ -n "$pid" ]]; then
        if _is_win; then
            taskkill /PID "$pid" /F > /dev/null 2>&1 || true
        else
            kill -9 "$pid" > /dev/null 2>&1 || true
        fi
    fi
    "$0" recovery-functions -S
}

# @cmd Check the mcp bridge server is running
check() {
    if [[ -f "$MCP_JSON_PATH" ]]; then
        echo "Check mcp/bridge" 
        pid="$(get-server-pid)"
        if [[ -z "$pid" ]]; then
            stop
            echo "✗ server is not running"
        fi
    fi
}

# @cmd Run the mcp tool
# @arg tool![`_choice_tool`] The tool name
# @arg json The json data
run@tool() {
    if [[ -z "$argc_json" ]]; then
        declaration="$(generate-declarations | jq --arg tool "$argc_tool" -r '.[] | select(.name == $tool)')"
        if [[ -n "$declaration" ]]; then
            _ask_json_data "$declaration"
        fi
    fi
    if [[ -z "$argc_json" ]]; then
        _die "error: no JSON data"
    fi
    bash "$ROOT_DIR/scripts/run-mcp-tool.sh" "$argc_tool" "$argc_json"
}

# @cmd Show the logs
# @flag -f --follow Follow mode
logs() {
    if [[ ! -f "$MCP_LOG_FILE" ]]; then
        _die "error: not found log file at '$MCP_LOG_FILE'"
    fi
    if [[ -n "$argc_follow" ]]; then
        tail -f "$MCP_LOG_FILE"
    else
        cat "$MCP_LOG_FILE"
    fi
}

# @cmd Build tools to bin
build-bin() {
    mkdir -p "$BIN_DIR"
    tools=( $(generate-declarations | jq -r '.[].name') )
    for tool in "${tools[@]}"; do
        if _is_win; then
            bin_file="$BIN_DIR/$tool.cmd"
            _build_win_shim > "$bin_file"
        else
            bin_file="$BIN_DIR/$tool"
            ln -s -f "$ROOT_DIR/scripts/run-mcp-tool.sh" "$bin_file"
        fi
        echo "Build bin/$tool"
    done
}

# @cmd Merge mcp tools into functions.json
# @flag -S --save Save to functions.json
merge-functions() {
    local tmpdir="$(mktemp -d)"
    "$0" recovery-functions > "$tmpdir/1.json"
    generate-declarations > "$tmpdir/2.json"
    result="$(jq -s '.[0] + .[1]' "$tmpdir/1.json" "$tmpdir/2.json")"
    if [[ -n "$argc_save" ]]; then
        printf "%s" "$result" > "$FUNCTIONS_JSON_PATH"
    else
        printf "%s" "$result"
    fi
}

# @cmd Unmerge mcp tools from functions.json
# @flag -S --save Save to functions.json
recovery-functions() {
    functions="[]"
    if [[ -f  "$FUNCTIONS_JSON_PATH" ]]; then
        functions="$(cat "$FUNCTIONS_JSON_PATH")"
    fi
    result="$(printf "%s" "$functions" | jq 'map(select(has("mcp") | not))')"
    if [[ -n "$argc_save" ]]; then
        printf "%s" "$result" > "$FUNCTIONS_JSON_PATH"
    else
        printf "%s" "$result"
    fi
}

# @cmd Generate function declarations for the mcp tools
generate-declarations() {
    pid="$(get-server-pid)"
    if [[ -n "$pid" ]]; then
        curl -sS http://localhost:$MCP_BRIDGE_PORT/tools
    else
        echo "[]"
    fi
}

# @cmd Wait for the mcp bridge server to ready
wait-for-server() {
    while true; do
        if [[ "$(curl -fsS --max-time 5 http://localhost:$MCP_BRIDGE_PORT/health 2>&1)" == "OK" ]]; then
            break;
        fi
        sleep 1
    done
}

# @cmd Get the server pid
get-server-pid() {
    curl -fsS --max-time 5 http://localhost:$MCP_BRIDGE_PORT/pid 2>/dev/null || true
}

_ask_json_data() {
    declaration="$1"
    echo 'Missing the JSON data but here are its properties:'
    echo "$declaration" | ./scripts/declarations-util.sh pretty-print | sed -n '2,$s/^/>/p'
    echo 'Generate placeholder data:'
    data="$(echo "$declaration" | _declarations_json_data)"
    echo ">  $data"
    read -e -r -p 'JSON data (Press ENTER to use placeholder): ' res
    if [[ -z "$res" ]]; then
        argc_json="$data"
    else
        argc_json="$res"
    fi
}

_declarations_json_data() {
   ./scripts/declarations-util.sh generate-json | tail -n +2
}

_build_win_shim() {
    run="\"$(argc --argc-shell-path)\" --noprofile --norc"
    cat <<-EOF
@echo off
setlocal

set "bin_dir=%~dp0"
for %%i in ("%bin_dir:~0,-1%") do set "script_dir=%%~dpi"
set "script_name=%~n0"

$run "%script_dir%scripts\run-mcp-tool.sh" "%script_name%" %*
EOF
}

_is_win() {
    if [[ "$OS" == "Windows_NT" ]]; then
        return 0
    else
        return 1
    fi
}

_choice_tool() {
    generate-declarations | jq -r '.[].name'
}

_die() {
    echo "$*" >&2
    exit 1
}

# See more details at https://github.com/sigoden/argc
eval "$(argc --argc-eval "$0" "$@")"
