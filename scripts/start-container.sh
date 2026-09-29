#!/usr/bin/env bash
set -euo pipefail

export DISPLAY_NUMBER="${DISPLAY_NUMBER:-99}"
export ENABLE_VNC="${ENABLE_VNC:-1}"
exec /usr/lib/task-ai-desktop/start-headless-session.sh
