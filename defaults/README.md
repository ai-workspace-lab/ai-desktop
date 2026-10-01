# AI Desktop defaults

- ICEWM root menu opens XLaunch and omits `icewm-menu-fdo`.
- XLaunch compact Menu is anchored to the lower-left work area and its bottom
  edge meets the XDock strut; full-screen APP Launch remains available via
  Enter, F11, or `全部应用`.
- XDock uses a static 78 px dock with hover/fish-eye animations disabled.
- ICEWM keeps native maximize/minimize controls (`Alt+F10`/`Alt+F9`) and avoids
  opaque move/resize rendering for low CPU use.

- XLaunch keeps only a 32 px user/session button and collapse button at the
  bottom right. Login/logout/power appear once in a right-aligned 240 px popup.
  Amber menu text and disabled states are explicit; disruptive actions require
  confirmation with Cancel initially focused.
- XDock uses real application icons, supports pin/unpin and drag ordering,
  and exposes user/session actions from its right-side avatar.
- Fullscreen uses screen geometry, including the Dock area; compact Menu uses
  the work area above the Dock.
- Optional Home-Ubuntu SDDM readability files are in `sddm/`; they are shipped
  as references and require an existing compatible theme. ISO stays LightDM.
