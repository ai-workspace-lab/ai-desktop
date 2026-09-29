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
| `task-ai-desktop-vps` | VPS | Xorg + XRDP 或 xpra |
| `task-ai-desktop-container` | 容器 | Xvfb + dbus-run-session + tini |

容器 profile 不依赖 systemd；VPS profile 不强制安装显示管理器；桌面电脑
可以在现有登录管理器中选择 ICEWM。

XLaunch 默认进入简约 Menu。Enter、F11 或“全部应用”进入全屏 APP Launch；
Menu 或 Esc 返回简约模式。

## Home-Ubuntu

目标环境是 Ubuntu 26.04 + ICEWM + X11。XLaunch Console/API 可以继续使用
systemd 用户服务，但 XDock 和 XLaunch 的原生桌面启动不依赖 systemd。
