#!/usr/bin/env bash
set -euo pipefail

DISPLAY_NUMBER="${DISPLAY_NUMBER:-99}"
export DISPLAY="${DISPLAY:-:${DISPLAY_NUMBER}}"
SCREEN="${SCREEN:-1920x1080x24}"
DISPLAY_BACKEND="${DISPLAY_BACKEND:-xvfb}"
VNC_PORT="${VNC_PORT:-5900}"
NOVNC_PORT="${NOVNC_PORT:-8080}"
ENABLE_VNC="${ENABLE_VNC:-1}"
ENABLE_NOVNC="${ENABLE_NOVNC:-0}"

if [[ "${DISPLAY_BACKEND}" != "xvfb" ]]; then
    echo "task-ai-desktop: unsupported display backend '${DISPLAY_BACKEND}'; use xvfb (Wayland is reserved for a future backend)" >&2
    exit 2
fi

export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-x11}"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
# Xvfb has no DRI device; keep Mesa and Qt clients on software rendering.
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"

Xvfb "${DISPLAY}" -screen 0 "${SCREEN}" -nolisten tcp &
xvfb_pid=$!
vnc_pid=""
novnc_pid=""

cleanup() {
    [[ -n "${novnc_pid}" ]] && kill "${novnc_pid}" 2>/dev/null || true
    [[ -n "${vnc_pid}" ]] && kill "${vnc_pid}" 2>/dev/null || true
    kill "${xvfb_pid}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

if command -v xdpyinfo >/dev/null 2>&1; then
    for _ in {1..50}; do
        xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1 && break
        sleep 0.1
    done
    xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1 || {
        echo "task-ai-desktop: Xvfb did not become ready on ${DISPLAY}" >&2
        exit 1
    }
else
    sleep 0.2
fi

if [[ "${ENABLE_VNC}" == "1" ]]; then
    if ! command -v x11vnc >/dev/null 2>&1; then
        echo "task-ai-desktop: x11vnc is required when ENABLE_VNC=1" >&2
        exit 1
    fi
    x11vnc -display "${DISPLAY}" -forever -shared -nopw -rfbport "${VNC_PORT}" \
        ${X11VNC_ARGS:-} >/tmp/task-ai-desktop-x11vnc.log 2>&1 &
    vnc_pid=$!
fi

if [[ "${ENABLE_NOVNC}" == "1" ]]; then
    NOVNC_PROXY="${NOVNC_PROXY:-}"
    if [[ -z "${NOVNC_PROXY}" ]] && command -v novnc_proxy >/dev/null 2>&1; then
        NOVNC_PROXY="$(command -v novnc_proxy)"
    fi
    if [[ -z "${NOVNC_PROXY}" && -x /usr/share/novnc/utils/novnc_proxy ]]; then
        NOVNC_PROXY=/usr/share/novnc/utils/novnc_proxy
    fi
    if [[ -z "${NOVNC_PROXY}" ]]; then
        echo "task-ai-desktop: noVNC proxy not found; install novnc and websockify" >&2
        exit 1
    fi
    "${NOVNC_PROXY}" --vnc "127.0.0.1:${VNC_PORT}" --listen "${NOVNC_PORT}" \
        ${NOVNC_ARGS:-} >/tmp/task-ai-desktop-novnc.log 2>&1 &
    novnc_pid=$!
fi

dbus-run-session -- sh -c '/usr/lib/task-ai-desktop/start-session.sh & exec icewm-session' &
session_pid=$!
wait "${session_pid}"
