# task-ai-desktop

`task-ai-desktop` 是面向 AI Workspace 的轻量 X11 桌面包。它保留 ICEWM
作为窗口管理器，并组合 XDock、XLaunch、终端、文件浏览器和 Web 浏览器。

```text
ICEWM 会话
  ├── XLaunch 简约 Menu → 全屏 APP Launch
  ├── XDock EWMH Dock
  ├── xfce4-terminal
  ├── Thunar + GVFS
  └── Chromium 或 Firefox ESR
```

## 运行 profile

| 包 | 用途 | 显示方式 |
| --- | --- | --- |
| `task-ai-desktop` | 桌面电脑 | 使用现有 Xorg/显示管理器 |
| `task-ai-desktop-vps` | VPS | Xvfb + X11VNC + ICEWM |
| `task-ai-desktop-container` | 容器 | Xvfb + X11VNC + 可选 noVNC |

容器 profile 不依赖 systemd；VPS profile 使用纯 CPU 的 Xvfb，不需要物理
显示器或 GPU；桌面电脑可以在现有登录管理器中选择 ICEWM。

无头会话链路为 `Xvfb → ICEWM → X11VNC → noVNC`。当前统一入口是
`/usr/lib/task-ai-desktop/start-headless-session.sh`，设置
`ENABLE_NOVNC=1` 可在 8080 端口提供浏览器访问。Chromium 容器建议把
`/dev/shm` 提高到至少 2 GiB（Docker 使用 `--shm-size=2g`，Kubernetes
使用内存型 `emptyDir`），并安装 CJK 字体；Debian 使用 `fonts-noto-cjk`，
Alpine 可使用 `font-wqy-zenhei`。

当前无头显示后端固定为 Xvfb。保留 `DISPLAY_BACKEND` 接口，为未来引入
Weston/wlroots + Xwayland 的软件渲染 Wayland 后端预留位置；ICEWM、XDock
的 EWMH 集成目前仍以 X11 为主，因此暂不启用 Wayland。

第一版本以 Debian + ai-desktop 定制 ISO 为主线，仓库职责、PR 顺序、构建
命令和验收标准见 [`docs/PROJECT_PLAN.md`](docs/PROJECT_PLAN.md)。

XLaunch 默认进入简约 Menu。Enter、F11 或“全部应用”进入全屏 APP Launch；
Menu 或 Esc 返回简约模式。

## Home-Ubuntu

目标环境是 Ubuntu 26.04 + ICEWM + X11。XLaunch Console/API 可以继续使用
systemd 用户服务，但 XDock 和 XLaunch 的原生桌面启动不依赖 systemd。
