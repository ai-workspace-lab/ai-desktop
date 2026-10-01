# Home-Ubuntu SDDM 可读性配置（可选）

适用于已安装 ubuntu-budgie-login-zh 自定义主题的主机。默认 ISO 仍使用
LightDM；这些文件只作为配置参考随 core 安装，不自动启用 SDDM，也不包含
第三方主题源码。新系统应先安装兼容主题和 fonts-noto-cjk，否则不要应用。

修改前备份 /etc/sddm.conf.d 和主题的 theme.conf。审核后安装：

```sh
sudo install -m 0644 theme.conf /usr/share/sddm/themes/ubuntu-budgie-login-zh/theme.conf
sudo install -m 0644 ai-desktop-dark.svg /usr/share/sddm/themes/ubuntu-budgie-login-zh/backgrounds/ai-desktop-dark.svg
sudo install -m 0644 90-ai-desktop-readable.conf /etc/sddm.conf.d/90-ai-desktop-readable.conf
```

固定深色背景，停止继承账户壁纸，输入框和菜单采用不透明深色背景与浅色
文字，使用 Noto CJK 字体，关闭动画和模糊。配置在下一次 greeter 启动时
生效；不应在用户工作期间自动重启 SDDM。回滚时恢复备份文件。

Home-Ubuntu 已应用配置并生成预览；物理登录屏幕仍需下一次登录实机验收。
