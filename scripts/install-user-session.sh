#!/usr/bin/env bash
set -euo pipefail

ICEWM_DIR="${HOME}/.icewm"
STARTUP="${ICEWM_DIR}/startup"
MENU="${ICEWM_DIR}/menu"
PREFERENCES="${ICEWM_DIR}/preferences"
DEFAULT_ROOT="${TASK_AI_DESKTOP_DEFAULTS:-/usr/share/task-ai-desktop/defaults}"
XDOCK_BIN="${XDOCK_BIN:-/opt/task-ai-desktop/bin/xdock}"
XLAUNCH_BIN="${XLAUNCH_BIN:-/opt/task-ai-desktop/bin/xlaunch}"
FORCE_DEFAULTS="${TASK_AI_DESKTOP_FORCE_DEFAULTS:-0}"

mkdir -p "${ICEWM_DIR}" "${HOME}/.config/ai-workspace-lab"

if [[ "${FORCE_DEFAULTS}" == "1" || ! -e "${HOME}/.config/ai-workspace-lab/XDock.conf" ]]; then
    if [[ -f "${DEFAULT_ROOT}/xdock/XDock.conf" ]]; then
        cp "${DEFAULT_ROOT}/xdock/XDock.conf" "${HOME}/.config/ai-workspace-lab/XDock.conf"
    fi
fi

if [[ "${FORCE_DEFAULTS}" == "1" || ! -e "${MENU}" ]]; then
    if [[ -f "${DEFAULT_ROOT}/icewm/menu" ]]; then
        sed "s#@XLAUNCH_BIN@#${XLAUNCH_BIN}#g" "${DEFAULT_ROOT}/icewm/menu" >"${MENU}"
    else
        printf '#!/bin/sh\n' >"${MENU}"
    fi
fi

if [[ ! -e "${PREFERENCES}" ]]; then
    cp "${DEFAULT_ROOT}/icewm/preferences" "${PREFERENCES}"
elif [[ -f "${DEFAULT_ROOT}/icewm/preferences" ]]; then
    while IFS= read -r line; do
        [[ -z "${line}" || "${line}" == \#* || "${line}" != *=* ]] && continue
        key="${line%%=*}"
        grep -q "^${key}=" "${PREFERENCES}" || printf '%s\n' "${line}" >>"${PREFERENCES}"
    done <"${DEFAULT_ROOT}/icewm/preferences"
fi

if [[ ! -e "${STARTUP}" ]]; then
    printf '#!/bin/sh\n' >"${STARTUP}"
    chmod 700 "${STARTUP}"
fi
if ! grep -Fq 'task-ai-desktop/start-session.sh' "${STARTUP}"; then
    cat >>"${STARTUP}" <<SESSION

# task-ai-desktop
export XDOCK_BIN="${XDOCK_BIN}"
export XLAUNCH_BIN="${XLAUNCH_BIN}"
/usr/lib/task-ai-desktop/start-session.sh &
SESSION
fi
