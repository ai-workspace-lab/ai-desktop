# Debian OCI image

This image uses the same Debian packages as the ISO and runs the same desktop
session without systemd, LightDM or a physical display.

## Build

Put the locally built packages in `debs/` at the repository root. The directory
must contain at least:

```text
task-ai-desktop-core_*.deb
task-ai-desktop-session_*.deb
task-ai-desktop-xdock_*.deb
task-ai-desktop-xlaunch_*.deb
task-ai-desktop-apps_*.deb
task-ai-desktop_*.deb
task-ai-desktop-container_*.deb
xdock_*.deb
xlaunch_*.deb
```

Build with Docker or Podman from the repository root:

```sh
podman build -f containers/debian/Containerfile -t task-ai-desktop:debian13 .
```

## Run

The container starts `Xvfb :99 → dbus-run-session → ICEWM`, then XDock and
XLaunch. Enable browser access through noVNC on port 8080:

```sh
podman run --rm --shm-size=2g \
  -e ENABLE_NOVNC=1 \
  -p 8080:8080 -p 5900:5900 \
  task-ai-desktop:debian13
```

The runtime contract is `DISPLAY=:99`, `QT_QPA_PLATFORM=xcb` and
`XDG_CURRENT_DESKTOP=ICEWM`. `/usr/lib/task-ai-desktop/healthcheck.sh` verifies
the X display, ICEWM, XDock and XLaunch processes.
