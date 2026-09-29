# task-ai-desktop 项目计划

## 目标

把 `ai-desktop` 做成可重复构建的 Debian + ICEWM + XDock + XLaunch 定制
ISO。第一版本优先完成组件集成、离线 `.deb` 装配、Live ISO 构建和
Home-Ubuntu 验收；桌面美化、Wayland 和 Alpine 镜像放到后续版本。

目标运行链路：

```text
Debian Live ISO
  └── ICEWM/X11 会话
        ├── XLaunch：简约 Menu ↔ 全屏 APP Launch
        ├── XDock：X11/XCB + EWMH Dock
        ├── xfce4-terminal
        ├── Thunar + GVFS
        └── Chromium 或 Firefox ESR
```

无物理显示器的 VPS 或容器使用同一套桌面会话：

```text
Xvfb → ICEWM → XDock/XLaunch → X11VNC → 可选 noVNC/websockify
```

当前版本不引入 TigerVNC。`DISPLAY_BACKEND=xvfb` 是当前唯一实现；
Wayland 仅保留后端接口和设计位置。

包拆分、运行配置和 OCI 镜像的详细契约见
[`docs/PACKAGE_ARCHITECTURE.md`](PACKAGE_ARCHITECTURE.md)。

## 包结构与运行边界

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

`task-ai-desktop` 是完整桌面元包；core、session、组件和 apps 可以单独
安装。VPS profile 默认走 `Xvfb + X11VNC`，同时推荐 Xorg、XRDP、xpra、
noVNC 和 websockify 作为可选传输。容器 profile 使用 `tini + Xvfb +
dbus-run-session + ICEWM`，OCI 定义位于 `containers/debian/Containerfile`。

开发工具链不进入运行时核心包，使用 `task-ai-desktop-dev` 作为建议入口，
实际版本继续由 Home-Ubuntu 基线清单控制。

## V1 交付范围

- [ ] 在 Debian 13 构建机上安装 `live-build`、`debootstrap`、`xorriso`、
      `squashfs-tools` 和 `rsync`。
- [ ] 构建 XDock 的 Linux/X11 `.deb`，验证 ICEWM 下 EWMH Dock 类型、
      above 状态和 partial strut。
- [ ] 构建 XLaunch 的 Linux/X11 `.deb`，验证 freedesktop 应用发现、
      `gio` 启动、Menu/全屏切换和图标主题读取。
- [ ] 构建 `task-ai-desktop` 元包及两个 profile：
      `task-ai-desktop-vps`、`task-ai-desktop-container`，并拆分 core、
      session、XDock、XLaunch、apps 子包。
- [ ] 构建 Debian 13 OCI 镜像，验证 `/usr/bin/tini`、Xvfb、ICEWM、XDock、
      XLaunch 和 healthcheck，不依赖 systemd。
- [ ] 将三个组件包复制到 isobuilder 的 `config/packages.chroot`，
      通过 `live-build` 生成可启动 ISO。
- [ ] ISO 默认安装 ICEWM、X11、字体、终端、文件浏览器、浏览器、Xvfb、
      X11VNC，并可选安装 noVNC/websockify。
- [ ] 首次登录自动启动 XDock 和 XLaunch；菜单项指向安装后的
      `/opt/task-ai-desktop/bin/xlaunch`。
- [ ] 在 Home-Ubuntu（`10.79.0.7`）验证 X11 会话、VPS 无头会话和
      本地项目目录挂载，不把 MacOS 的路径写死到运行时。

## 仓库职责与 PR

| 阶段 | 仓库 | 交付物 | 当前 PR |
| --- | --- | --- | --- |
| A | `XDock` | X11/XCB + EWMH 后端、LayerShellQt 可选、Debian 包 | [PR #2](https://github.com/ai-workspace-lab/XDock/pull/2) |
| B | `XLaunch` | Linux 应用目录、ICEWM Menu、全屏 Launch 模式、Debian 包 | [PR #31](https://github.com/ai-workspace-lab/XLaunch/pull/31) |
| C | `ai-desktop` | 元包、VPS/容器 profile、Xvfb 无头入口、版本契约 | [PR #1](https://github.com/ai-workspace-lab/ai-desktop/pull/1) |
| D | `isobuilder` | Debian 13 Live ISO profile、skel ICEWM 配置、构建脚本 | [PR #2](https://github.com/haitaopanhq/isobuilder/pull/2) |

合并顺序为 A/B → C → D。D 只消费已经生成的 `.deb`，不在 ISO 构建阶段
从 GitHub 拉取源码，保证离线重建和审计路径稳定。

## V1 构建流程

1. 在 Home-Ubuntu 或 Debian 13 构建机准备源码：

   ```text
   workspaces/
   ├── ai-desktop/
   ├── XDock/
   ├── XLaunch/
   └── isobuilder/
   ```

2. 编译并生成 XDock、XLaunch、ai-desktop `.deb`。包名契约为：
   `xdock`、`xlaunch`、`task-ai-desktop-core`、`task-ai-desktop-session`、
   `task-ai-desktop-xdock`、`task-ai-desktop-xlaunch`,
   `task-ai-desktop-apps`、`task-ai-desktop`、`task-ai-desktop-vps` 和
   `task-ai-desktop-container`。

3. 使用 isobuilder 的 ISO profile：

   ```sh
   cd isobuilder/debian-ai-desktop-iso
   AI_DESKTOP_DEB_DIR=/path/to/debs ./build.sh
   ```

4. 从 ISO 启动，验收 ICEWM 会话、XLaunch 菜单、XDock、终端、Thunar、
   Chromium/Firefox 和字体。无显示器验收使用：

   ```sh
   ENABLE_NOVNC=1 /usr/lib/task-ai-desktop/start-headless-session.sh
   ```

5. 构建并运行 OCI 镜像：

   ```sh
   podman build -f containers/debian/Containerfile -t task-ai-desktop:debian13 .
   podman run --rm --shm-size=2g -e ENABLE_NOVNC=1 \
     -p 8080:8080 -p 5900:5900 task-ai-desktop:debian13
   ```

## 版本基线

Home-Ubuntu 对齐的工具版本清单：

| 工具 | 版本 |
| --- | --- |
| Git | 2.54.0 |
| GitHub CLI | 2.98.0 |
| Terraform | 1.16.0 |
| Ansible | 2.21.3 |
| Python | 3.14.7 |
| Go | 1.26.4 |
| Node.js | 24.20.0 |
| npm | 11.19.0 |
| pnpm | 12.4.2 |
| jq | 1.7.1 |
| Google Cloud CLI | 584.0.0 |

这些版本用于构建机和远程开发环境的基线检查；桌面运行时不需要全部
安装。Qt 6、CMake、C++ 编译器和 X11 开发包由 XDock/XLaunch 的构建说明
单独声明。

## V1 验收标准

- ISO 能在 BIOS/UEFI 虚拟机启动并进入 ICEWM。
- `xlaunch` 和 `xdock` 来自 Debian 包，运行时不依赖源码目录。
- XLaunch 默认是简约 Menu，Enter/F11/“全部应用”可进入全屏模式。
- XDock 在 ICEWM/X11 下不依赖 Wayland LayerShellQt。
- `DISPLAY_BACKEND=xvfb` 可在无 GPU 的 VPS/容器启动；X11VNC 可连接，
  `ENABLE_NOVNC=1` 时浏览器可访问 8080。
- CJK 文本正常显示；Chromium 容器的 `/dev/shm` 至少 2 GiB。
- 同一套包和脚本可在 Home-Ubuntu 本地 X11 会话复用。
- Debian OCI 镜像的 healthcheck 能检测 X display、ICEWM、XDock 和 XLaunch。
- `/opt/task-ai-desktop/bin/xdock`、`xlaunch` 和 `XLaunch` 兼容别名可用。

## V1 之外

- Weston/wlroots + Xwayland 的软件渲染 Wayland 后端。
- Alpine 专用镜像和 apk 包装。
- GPU 加速、视频编码优化、桌面动画和复杂主题同步。
- 包签名仓库、自动更新服务和多架构发布。

Wayland 后端的预留约束：继续复用 ICEWM/XDock/XLaunch 的会话接口，
使用软件渲染（例如 `WLR_RENDERER=pixman`），并通过 Xwayland 兼容当前
X11 应用；在 V1 的 Xvfb 路径稳定前不切换默认后端。
