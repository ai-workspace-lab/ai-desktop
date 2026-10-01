#!/usr/bin/env bash
set -euo pipefail
export DISPLAY="${DISPLAY:-:99}"
xdpyinfo -display "$DISPLAY" >/dev/null 2>&1
found_icewm=0 found_xlaunch=0 found_xdock=0
for process in /proc/[0-9]*; do
    [[ -r "$process/comm" && -r "$process/environ" ]] || continue
    name=$(cat "$process/comm" 2>/dev/null) || continue
    case "$name" in icewm|xlaunch|xdock) ;; *) continue ;; esac
    process_display=""
    while IFS= read -r -d '' entry; do
        if [[ "$entry" == DISPLAY=* ]]; then process_display="${entry#DISPLAY=}"; break; fi
    done < "$process/environ" || continue
    [[ "${process_display%%.*}" == "${DISPLAY%%.*}" ]] || continue
    case "$name" in icewm) found_icewm=1 ;; xlaunch) found_xlaunch=1 ;; xdock) found_xdock=1 ;; esac
done
[[ "$found_icewm" == 1 && "$found_xlaunch" == 1 ]]
[[ "${ENABLE_XDOCK:-1}" == 0 || "$found_xdock" == 1 ]]
