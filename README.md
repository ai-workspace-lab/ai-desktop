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
| `task-ai-desktop` | desktop computer | existing Xorg/display manager |
| `task-ai-desktop-vps` | VPS | Xorg + XRDP or xpra |
| `task-ai-desktop-container` | OCI/container | Xvfb + dbus-run-session + tini |

The package does not force a display manager. On a desktop, select ICEWM in
the existing display manager. On a VPS, install the VPS profile and choose
XRDP or xpra. In a container, the profile avoids systemd and starts a private
X display.

The container entrypoint is `/usr/lib/task-ai-desktop/start-container.sh`; it
starts Xvfb, a D-Bus session, ICEWM, XDock and XLaunch under `tini`.

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
