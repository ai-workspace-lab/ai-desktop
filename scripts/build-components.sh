#!/usr/bin/env bash
set -euo pipefail

XDOCK_SOURCE="${1:-../XDock}"
XLAUNCH_SOURCE="${2:-../XLaunch}"
BUILD_ROOT="${BUILD_ROOT:-$(pwd)/build/task-ai-desktop}"
INSTALL_ROOT="${INSTALL_ROOT:-/opt/task-ai-desktop}"

cmake -S "${XDOCK_SOURCE}" -B "${BUILD_ROOT}/xdock" \
    -DCMAKE_BUILD_TYPE=Release -DXDOCK_ENABLE_LAYER_SHELL=ON
cmake --build "${BUILD_ROOT}/xdock" --parallel
sudo cmake --install "${BUILD_ROOT}/xdock" --prefix "${INSTALL_ROOT}"

cmake -S "${XLAUNCH_SOURCE}/launcher" -B "${BUILD_ROOT}/xlaunch" \
    -DCMAKE_BUILD_TYPE=Release
cmake --build "${BUILD_ROOT}/xlaunch" --parallel
sudo cmake --install "${BUILD_ROOT}/xlaunch" --prefix "${INSTALL_ROOT}"
