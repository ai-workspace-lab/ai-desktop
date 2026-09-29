#!/usr/bin/env bash
set -euo pipefail

XDOCK_BIN="${XDOCK_BIN:-/opt/task-ai-desktop/bin/xdock}"
XLAUNCH_BIN="${XLAUNCH_BIN:-/opt/task-ai-desktop/bin/XLaunch}"
STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/task-ai-desktop"
mkdir -p "${STATE_DIR}"

export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-ICEWM}"

start_once() {
    local name="$1" binary="$2" log_file="$3"
    if [[ ! -x "${binary}" ]]; then
        printf '[task-ai-desktop] missing %s: %s\n' "${name}" "${binary}" >&2
        return 0
    fi
    if pgrep -x -u "$(id -u)" "${name}" >/dev/null 2>&1; then
        return 0
    fi
    nohup "${binary}" >"${log_file}" 2>&1 </dev/null &
}

start_once xdock "${XDOCK_BIN}" "${STATE_DIR}/xdock.log"
start_once XLaunch "${XLAUNCH_BIN}" "${STATE_DIR}/xlaunch.log"
