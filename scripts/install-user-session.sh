#!/usr/bin/env bash
set -euo pipefail

ICEWM_DIR="${HOME}/.icewm"
STARTUP="${ICEWM_DIR}/startup"
MENU="${ICEWM_DIR}/menu"
mkdir -p "${ICEWM_DIR}"

if [[ ! -e "${STARTUP}" ]]; then
    printf '#!/bin/sh\n' >"${STARTUP}"
    chmod 700 "${STARTUP}"
fi
if ! grep -Fq 'task-ai-desktop/start-session.sh' "${STARTUP}"; then
    printf '\n# task-ai-desktop\n/usr/lib/task-ai-desktop/start-session.sh &\n' >>"${STARTUP}"
fi

touch "${MENU}"
if ! grep -Fq 'task-ai-desktop XLaunch' "${MENU}"; then
    printf '\n# task-ai-desktop XLaunch\nprog "task-ai-desktop XLaunch" xlaunch /opt/task-ai-desktop/bin/xlaunch\n' >>"${MENU}"
fi
