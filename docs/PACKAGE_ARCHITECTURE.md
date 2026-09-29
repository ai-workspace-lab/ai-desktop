# task-ai-desktop 包与运行架构

## 设计决定

`task-ai-desktop` 是 Debian/Ubuntu 元包，负责把统一的 ICEWM、XDock、
XLaunch 和桌面应用组合起来。运行目标分成桌面电脑、VPS 和 OCI 容器，
核心 UI 和用户配置契约保持一致。

ICEWM 继续作为 X11 窗口管理器。XDock 在 X11 中通过 EWMH 属性协作：

- `_NET_WM_WINDOW_TYPE_DOCK`
- `_NET_WM_STATE_ABOVE`
- `_NET_WM_STRUT_PARTIAL`

EWMH/ICCCM 是窗口管理协议，ICEWM 是实现这些协议的窗口管理器。参考：
[IceWM 手册](https://ice-wm.org/manual/)、
[EWMH 规范](https://specifications.freedesktop.org/wm/latest-single/)。

当前无头默认链路是 `Xvfb → ICEWM → XDock/XLaunch`，可选接上
`X11VNC → noVNC/websockify`。不引入 TigerVNC。Wayland 只保留后端接口，
待 X11 版本稳定后再评估 Weston/wlroots + Xwayland 软件渲染。

## Debian 包层级

```text
task-ai-desktop
├── task-ai-desktop-core
├── task-ai-desktop-session
├── task-ai-desktop-xdock
├── task-ai-desktop-xlaunch
├── task-ai-desktop-apps
├── task-ai-desktop-vps
├── task-ai-desktop-container
└── task-ai-desktop-dev
```

| 包 | 内容 | 默认安装方式 |
| --- | --- | --- |
| `task-ai-desktop-core` | X11、D-Bus、XDG、字体、图标、GVFS、Qt6/X11 runtime | 被 session 依赖 |
| `task-ai-desktop-session` | ICEWM session、startup/menu helper、Xvfb 入口、healthcheck | 被组件包依赖 |
| `task-ai-desktop-xdock` | 依赖 `xdock`，提供 `/opt/task-ai-desktop/bin/xdock` | 被总包依赖 |
| `task-ai-desktop-xlaunch` | 依赖 `xlaunch`，提供 `xlaunch` 和 `XLaunch` 兼容路径 | 被总包依赖 |
| `task-ai-desktop-apps` | xfce4-terminal、Thunar、GVFS、Chromium 或 Firefox ESR | 被总包依赖 |
| `task-ai-desktop` | 上述运行时的完整元包 | 桌面电脑默认入口 |
| `task-ai-desktop-vps` | Xvfb、X11VNC；可选 Xorg、XRDP、xpra、noVNC | VPS profile |
| `task-ai-desktop-container` | Xvfb、X11VNC、tini、D-Bus；可选 noVNC | OCI profile |
| `task-ai-desktop-dev` | 开发工具链的建议入口，不强制安装工具 | 构建机按需安装 |

Linux 原生可执行文件使用小写 `xlaunch`。`/opt/task-ai-desktop/bin/XLaunch`
是兼容别名，避免旧的 ICEWM 菜单配置失效。

## 核心包职责

### `task-ai-desktop-core`

包含 `dbus-x11`、`xdg-utils`、`xdg-user-dirs`、X11 工具、认证工具、
Noto 字体、图标主题、GVFS、Qt6 Quick/QML/Widgets、QPA 插件、XCB 和
X11-XCB runtime。它不安装窗口管理器、浏览器或开发工具。

### `task-ai-desktop-session`

包含 ICEWM 会话集成：

- 读取 `~/.icewm/startup` 和 `~/.icewm/menu`
- 提供 `/usr/lib/task-ai-desktop/start-session.sh`
- 提供 `/usr/lib/task-ai-desktop/start-headless-session.sh`
- 提供 `/usr/lib/task-ai-desktop/healthcheck.sh`
- 为 `/opt/task-ai-desktop/bin` 创建组件路径别名

桌面显示管理器可以是 LightDM、GDM、SDDM 或已有登录流程，不由元包强制
绑定。

### `task-ai-desktop-xdock`

只负责 XDock 的安装和路径契约。XDock 自身负责底部 Dock、固定应用、
运行项和窗口切换；在 ICEWM/X11 中使用 EWMH Dock 属性，在 Wayland 中
使用可选 LayerShellQt。

### `task-ai-desktop-xlaunch`

只负责 XLaunch 的安装和路径契约。XLaunch 默认显示简约 Menu，支持应用
分类、搜索、Linux `.desktop` 发现、系统图标主题和 `gio` 启动；Enter、
F11、“全部应用”进入全屏 APP Launch，Menu/Esc 返回。

### `task-ai-desktop-apps`

把终端、文件管理器和 Web 浏览器从核心会话中分离出来：

```text
终端       xfce4-terminal
文件浏览器  Thunar + GVFS
Web 浏览器  Chromium 或 Firefox ESR
```

不把 Google Chrome 私有源写入核心依赖。

## 三种运行配置

### 桌面电脑

```text
显示管理器 → ICEWM session → XLaunch Menu + XDock
                                  └── Console/API 用户服务（可选）
```

安装 `task-ai-desktop`，在登录管理器选择 ICEWM。原生桌面启动不依赖
systemd；Console/API 可以继续使用 systemd 用户服务。

### VPS

默认使用无 GPU 的 Xvfb：

```text
Xvfb :99 → ICEWM → XDock/XLaunch → X11VNC
```

`task-ai-desktop-vps` 同时推荐 `xorg`、`xrdp`、`xpra`、`novnc` 和
`websockify`，便于按 VPS 网络条件选择 SSH 隧道、XRDP、xpra、VNC 或浏览器
访问。Xvfb 不需要物理显示器和 GPU；1920×1080×24 的原始 framebuffer 约
8 MiB，浏览器和 `/dev/shm` 通常是主要内存消耗。

### OCI 容器

`containers/debian/Containerfile` 使用本地 `.deb` 目录构建 Debian 13
镜像：

```text
tini → Xvfb :99 → dbus-run-session → icewm-session
                                      ├── XDock
                                      └── XLaunch
```

容器契约固定为：

```text
DISPLAY=:99
QT_QPA_PLATFORM=xcb
XDG_CURRENT_DESKTOP=ICEWM
```

需要浏览器访问时设置 `ENABLE_NOVNC=1` 并发布 TCP 8080。Chromium 容器
建议 `--shm-size=2g`；Kubernetes 使用内存型 `emptyDir`。

## 配置与目录契约

```text
/opt/task-ai-desktop/
├── bin/
│   ├── xdock
│   ├── xlaunch
│   └── XLaunch -> xlaunch
├── lib/
└── share/

/usr/lib/task-ai-desktop/
├── start-session.sh
├── start-headless-session.sh
├── start-container.sh
└── healthcheck.sh
```

用户配置和状态：

```text
~/.config/task-ai-desktop/
~/.local/state/task-ai-desktop/
~/.icewm/startup
~/.icewm/menu
```

## 开发工具链边界

Git、GitHub CLI、Terraform、Ansible、Python、Go、Node.js、npm、pnpm、jq
和 Google Cloud CLI 不进入核心运行包。它们属于构建机或
`task-ai-desktop-dev` 的建议范围，继续沿用 Home-Ubuntu 的版本基线。

## 验收标准

- 登录 ICEWM 后自动启动 XDock 和 XLaunch。
- XDock 在最大化窗口上方显示，并通过 EWMH 占位。
- XLaunch 默认是简约 Menu，可切换全屏 APP Launch。
- 终端、Thunar 和 Chromium/Firefox 可从 XLaunch 启动。
- XLaunch 能读取 Linux `.desktop` 文件并通过 `gio` 启动。
- VPS 可使用 Xvfb/X11VNC，也可选 Xorg/XRDP/xpra。
- OCI 容器不依赖 systemd、LightDM 或物理显示器。
- `healthcheck.sh` 能检测 X display、ICEWM、XDock 和 XLaunch。
- `DISPLAY_BACKEND=xvfb` 稳定后，再引入 Wayland 软件渲染后端。
