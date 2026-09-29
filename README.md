# task-ai-desktop

`task-ai-desktop` is a Debian/Ubuntu meta-package family for AI Workspace. It
keeps ICEWM as the X11 window manager and combines XDock, XLaunch, a terminal,
a file manager and a web browser. The same session contract is used on desktop
computers, VPS hosts and OCI containers.

The default shell is deliberately small:

```text
ICEWM session
  ├── XLaunch compact Menu → full-screen application launcher
  ├── XDock EWMH dock
  ├── xfce4-terminal
  ├── Thunar + GVFS
  └── Chromium or Firefox ESR
```

## Profiles

| Package | Use | Display model |
| --- | --- | --- |
| `task-ai-desktop` | desktop computer | existing Xorg/display manager |
| `task-ai-desktop-vps` | Debian 13 VPS | Xvfb + X11VNC + ICEWM |
| `task-ai-desktop-container` | OCI/container | Xvfb + X11VNC + optional noVNC |

The runtime is split into `task-ai-desktop-core`, `task-ai-desktop-session`,
`task-ai-desktop-xdock`, `task-ai-desktop-xlaunch` and
`task-ai-desktop-apps`. `task-ai-desktop` is the complete desktop meta-package;
`task-ai-desktop-dev` keeps the development toolchain separate.

The package does not force a display manager. On a desktop, select ICEWM in
the existing display manager. On a Debian 13 VPS, the VPS profile uses
Xvfb and X11VNC, with no physical display or GPU required. In a container,
the profile avoids systemd and starts the same private X display; X11VNC
exposes it as VNC and noVNC/websockify can expose it in a browser.

The shared entrypoint is `/usr/lib/task-ai-desktop/start-headless-session.sh`;
the container wrapper starts Xvfb, X11VNC, a D-Bus session, ICEWM, XDock and
XLaunch under `tini`. Set `ENABLE_NOVNC=1` to start noVNC on port 8080 (VNC
defaults to port 5900).

## Headless profiles

### Debian 13 VPS with Xvfb and X11VNC

Install `task-ai-desktop-vps`, then run the shared entrypoint with a private
display. VNC viewers connect to port 5900; set `ENABLE_NOVNC=1` to also expose
the desktop through a browser on port 8080:

```sh
DISPLAY_NUMBER=99 SCREEN=1920x1080x24 ENABLE_NOVNC=1 \
  /usr/lib/task-ai-desktop/start-headless-session.sh
```

Xvfb supplies the virtual X11 display and X11VNC exports it without requiring
Xorg, a physical display, or GPU memory.

The Debian package layout also provides `/opt/task-ai-desktop/bin/xdock`,
`xlaunch` and the compatibility alias `XLaunch` for existing ICEWM menu files.

Xvfb is the current headless display backend. It is a good fit for VPS and
containers because it has no GPU or compositor requirement, but it is a CPU
renderer: animated pages, video and large canvases consume CPU, and VNC adds
another capture/encoding cost. A 1920×1080×24 screen uses roughly 8 MiB for
the raw framebuffer; browser processes and `/dev/shm` are usually the larger
memory consumers.

### Alpine container with browser access

Use the same `start-container.sh` entrypoint after installing the Alpine
equivalents of `xvfb`, `icewm`, `x11vnc`, `novnc`, `websockify`, `dbus`, and
`font-wqy-zenhei`. The process chain is `Xvfb → ICEWM → X11VNC → noVNC`;
publish TCP 8080 for browser access. Set the container shared memory to at
least 2 GiB (`--shm-size=2g`, or a memory-backed Kubernetes `emptyDir`) when
running Chromium-based workloads.

Both profiles should include CJK fonts. Debian uses `fonts-noto-cjk`; Alpine
can use `font-wqy-zenhei` when that package is available in the selected
repository.

### Wayland reservation

The package keeps a display-backend seam (`DISPLAY_BACKEND=xvfb`) so a future
headless Wayland profile can be added without changing the ICEWM/XDock/XLaunch
session contract. A future backend may use Weston headless or wlroots with
software rendering and Xwayland for legacy X11 applications. It is not enabled
yet: ICEWM and the current XDock EWMH integration are X11 components, so Xvfb
remains the predictable no-GPU backend for Home-Ubuntu, Debian VPS and Alpine
containers.

## Components

- `task-ai-desktop`: X11, D-Bus, XDG, fonts, icons, GVFS and Qt runtime
  dependencies, plus the desktop applications.
- `task-ai-desktop-xdock`: XDock built from
  `git@github.com:ai-workspace-lab/XDock.git`.
- `task-ai-desktop-xlaunch`: XLaunch built from
  `git@github.com:ai-workspace-lab/XLaunch.git`.
- `scripts/start-session.sh`: starts XDock and XLaunch in an ICEWM session.
- `scripts/install-user-session.sh`: safely adds the shell to a user's
  `~/.icewm/startup` and `~/.icewm/menu`.

XLaunch opens in compact Menu mode. Enter, F11 or “全部应用” opens the full
screen application launcher; Menu or Esc returns to the compact mode.

## Build component binaries

Build from a workspace containing the three repositories:

```text
workspaces/
├── ai-desktop/
├── XDock/
└── XLaunch/
```

Then run:

```sh
./scripts/build-components.sh ../XDock ../XLaunch
```

The script installs the two native binaries under `/opt/task-ai-desktop/bin`.
The Debian package can instead depend on the `xdock` and `xlaunch` packages
produced by their source repositories.

## Home-Ubuntu

The intended target is Ubuntu 26.04 with an ICEWM X11 session. The package is
compatible with an existing user-level systemd setup, but does not require
systemd for the native desktop shell itself.

The staged ISO integration plan, package contract, acceptance checks and future
Wayland reservation are documented in [`docs/PROJECT_PLAN.md`](docs/PROJECT_PLAN.md).
The package split and OCI image contract are in
[`docs/PACKAGE_ARCHITECTURE.md`](docs/PACKAGE_ARCHITECTURE.md) and
[`containers/debian/README.md`](containers/debian/README.md).
