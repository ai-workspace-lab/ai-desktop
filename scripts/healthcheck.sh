#!/usr/bin/env bash
set -euo pipefail

DISPLAY="${DISPLAY:-:99}"
export DISPLAY

command -v xdpyinfo >/dev/null 2>&1
xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1
pgrep -f '[i]cewm' >/dev/null 2>&1
pgrep -x xdock >/dev/null 2>&1
pgrep -x xlaunch >/dev/null 2>&1
