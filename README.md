# task-ai-desktop

`task-ai-desktop` is a small X11 desktop bundle for AI Workspace. It keeps
ICEWM as the window manager and combines XDock, XLaunch, a terminal, a file
manager and a web browser into one installable Debian/Ubuntu meta-package.

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
| task-ai-desktop-core | shared runtime | X11/Qt/XLaunch, no DM or WM |
| task-ai-desktop-kde-plasma-core | daily KDE Plasma desktop | Plasma core + XLaunch menu; XDock optional |
| task-ai-desktop | ICEWM compatibility profile | ICEWM + XDock on top of core |
| task-ai-desktop-vps | Debian 13 VPS | Xvfb + X11VNC + ICEWM |
| task-ai-desktop-container | OCI/container | Xvfb + X11VNC + optional noVNC |

task-ai-desktop-core does not force a display manager or window manager, so it
can be reused by KDE, VPS and container profiles. The Debian + ai-desktop ISO
profile uses LightDM with the GTK greeter by default, supports SDDM as an
alternative display manager, and presents ICEWM as the default session. The
optional KDE Plasma core profile uses XLaunch as the application menu; XDock can
be installed separately when a dock is desired. On a
Debian 13 VPS, the VPS profile uses
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

- task-ai-desktop-core: shared X11, D-Bus, XDG, fonts, icons, GVFS and Qt
  runtime with XLaunch and the common terminal, file manager and browser.
- task-ai-desktop-kde-plasma-core: optional daily KDE Plasma core. XLaunch is
  started through KDE autostart as the AI application menu; XDock is optional.
- task-ai-desktop: compatibility profile that adds ICEWM and XDock to core.
- task-ai-desktop-vps: core plus ICEWM, Xvfb and X11VNC without a display manager.
- task-ai-desktop-container: core plus ICEWM, Xvfb, X11VNC and tini without
  systemd or a display manager.
- XDock and XLaunch are built from their standalone repositories and consumed
  as Debian packages.
- start-session.sh starts XDock and XLaunch in an ICEWM session.
- install-user-session.sh safely adds the ICEWM shell to a user profile.

XLaunch opens in compact Menu mode. Enter, F11 or “全部应用” opens the full
screen application launcher; Menu or Esc returns to the compact mode. The compact
Menu is anchored to the lower-left work area with its bottom edge aligned to the
top of the XDock strut; full-screen mode still covers the whole screen.

The default XDock profile is low power: fish-eye hover magnification, hover
scaling and dock geometry transitions are disabled while the 78 px EWMH strut
remains active. ICEWM owns native maximize/minimize actions (`Alt+F10` and
`Alt+F9`), and opaque move/resize rendering is disabled to reduce CPU use. The
default files live under `defaults/icewm/` and `defaults/xdock/`;
`install-user-session.sh` copies them into a user's configuration on first setup.

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

## OCI packaging and compatibility aliases

The current profiles are core, KDE Plasma core, ICEWM, VPS and container.
Optional session/component/apps aliases retain older package names without
changing core ownership or making KDE install ICEWM. Development tools remain
optional. See [package architecture](docs/PACKAGE_ARCHITECTURE.md) and the
[Debian OCI build contract](containers/debian/README.md). The OCI definition
consumes locally built distribution-compatible `.deb` files; an actual image
build and runtime acceptance remain required.
