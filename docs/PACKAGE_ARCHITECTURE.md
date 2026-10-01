# task-ai-desktop 包与运行架构

## 当前配置

| 包 | 内容 |
| --- | --- |
| task-ai-desktop-core | X11、D-Bus、字体、图标、Qt、GVFS、XLaunch、终端、文件管理器、浏览器、共享启动脚本 |
| task-ai-desktop-kde-plasma-core | 日常 KDE Plasma 桌面；XLaunch 菜单，XDock 可选 |
| task-ai-desktop | ICEWM + XDock 兼容桌面 |
| task-ai-desktop-vps | core + ICEWM + Xvfb + X11VNC，无 DM，XDock 可选 |
| task-ai-desktop-container | core + ICEWM + Xvfb + X11VNC + tini，无 DM/systemd，XDock 可选 |
| task-ai-desktop-dev | 仅建议开发工具，不强制安装工具链 |

ISO 默认 LightDM + GTK Greeter + ICEWM；SDDM 和 KDE 通过构建参数可选。
core 不选择窗口管理器或 DM。旧名称 session、xdock、xlaunch、apps 作为
可选兼容元包保留，既不迁移 core 的文件，也不强制 KDE 安装 ICEWM。

## 运行与目录

Xvfb → dbus-run-session → ICEWM → XLaunch + 可选 XDock → X11VNC → 可选 noVNC。
不引入 TigerVNC，Wayland 软件渲染仍为未来后端。

共享脚本由 core 安装到 `/usr/lib/task-ai-desktop/`：start-session.sh、
start-headless-session.sh、start-container.sh、healthcheck.sh。
组件兼容包提供 `/opt/task-ai-desktop/bin/xdock`、`xlaunch` 和 `XLaunch`
链接；原生组件仍由独立的 xdock / xlaunch 包安装。

用户配置位于 ~/.config/task-ai-desktop、~/.icewm；状态位于
~/.local/state/task-ai-desktop。Qt/X11 环境使用 DISPLAY=:99、
QT_QPA_PLATFORM=xcb、XDG_CURRENT_DESKTOP=ICEWM；不得把构建机源码路径
写死到会话脚本。

## OCI 构建与验收

`containers/debian/Containerfile` 使用 Debian 13 slim 和本地 `.deb`，
通过 tini 启动共享容器入口。构建目录与具体命令见同目录 README。
`ENABLE_NOVNC=1` 启动网页桌面；Chromium 运行建议 --shm-size=2g。
健康检查按当前 DISPLAY 匹配 ICEWM/XLaunch，只在 ENABLE_XDOCK 非 0
时要求 XDock。Xvfb 不需要 GPU，浏览器、视频和编码仍会消耗 CPU。

源码集成不代表镜像已构建，必须分别验收真实 OCI、BIOS/UEFI 启动、
USB Live 安装、中文字体和远程连接。开发工具链不进入核心必需依赖。
