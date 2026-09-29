#!/usr/bin/env bash
set -euo pipefail

DISPLAY_NUMBER="${DISPLAY_NUMBER:-99}"
export DISPLAY="${DISPLAY:-:${DISPLAY_NUMBER}}"
SCREEN="${SCREEN:-1920x1080x24}"

Xvfb "${DISPLAY}" -screen 0 "${SCREEN}" -nolisten tcp &
xvfb_pid=$!
trap 'kill "${xvfb_pid}" 2>/dev/null || true' EXIT INT TERM

exec dbus-run-session -- sh -c '/usr/lib/task-ai-desktop/start-session.sh & exec icewm-session'
