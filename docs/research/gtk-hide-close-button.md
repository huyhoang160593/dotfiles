# Hiding the X (close) button on GTK titlebars (mangowm, no GNOME session)

Research date: 2026-09-23. Machine: CachyOS/Arch, mangowm ("mango", dwl/wlroots-based) + Noctalia, fish.
Local versions: `gtk3 3.24.52`, `gtk4 4.22.5`, `libadwaita 1.9.4` (read-only `pacman -Q` check).

## Question

How can the user hide the close (X) button on GTK3, GTK4, and libadwaita titlebars under
mangowm, given that `gsettings set org.gnome.desktop.wm.preferences button-layout ...`
"does nothing"?

## Findings

### 1. Who actually reads `org.gnome.desktop.wm.preferences button-layout`

- **GTK and libadwaita never read this dconf key directly.** The key GTK apps read is the
  `GtkSettings` property **`gtk-decoration-layout`** (default `"menu:minimize,maximize,close"`),
  documented as determining "which buttons should be put in the titlebar of client-side
  decorated windows". GtkSettings sources are (in GTK3's own words) an **XSETTINGS manager**
  on X, or, in its absence, `settings.ini` files in `/etc/gtk-3.0`, `$XDG_CONFIG_DIRS/gtk-3.0`
  and `$XDG_CONFIG_HOME/gtk-3.0`
  ([gtksettings.c, gtk-3-24](https://raw.githubusercontent.com/GNOME/gtk/gtk-3-24/gtk/gtksettings.c),
  section header + `gtk_settings_init()` loading `$XDG_CONFIG_HOME/gtk-3.0/settings.ini`,
  and the `gtk-decoration-layout` property doc block). GTK4 states the same: platform
  sharing mechanisms (XSettings on X, a settings portal on Wayland), and "in the absence of
  these sharing mechanisms, GTK reads default values for settings from `settings.ini` files in
  `/etc/gtk-4.0`, `$XDG_CONFIG_DIRS/gtk-4.0` and `$XDG_CONFIG_HOME/gtk-4.0`"
  ([Gtk.Settings docs](https://docs.gtk.org/gtk4/class.Settings.html)).
- **The bridge from the dconf key to GTK is gnome-settings-daemon's xsettings plugin.**
  Its translation table contains exactly:
  `{ "org.gnome.desktop.wm.preferences", "button-layout", "Gtk/DecorationLayout", translate_button_layout }`,
  i.e. gsd-xsettings watches the dconf key and republishes it as the XSETTINGS string
  `Gtk/DecorationLayout`, which GTK3 (X11) picks up
  ([gsd-xsettings-manager.c](https://raw.githubusercontent.com/GNOME/gnome-settings-daemon/master/plugins/xsettings/gsd-xsettings-manager.c)).
  No gsd-xsettings → no translation → the dconf value reaches nothing.
- **Mutter reads the key for its own window frame** (server-side decoration layout):
  `preferences_string[]` contains `{ "button-layout", SCHEMA_GENERAL /* org.gnome.desktop.wm.preferences */, META_PREF_BUTTON_LAYOUT, button_layout_handler, ... }`
  ([mutter src/core/prefs.c](https://raw.githubusercontent.com/GNOME/mutter/main/src/core/prefs.c)).
  Mutter is not running under mangowm, so this reader is absent too.
- So on a GNOME session the chain is: dconf `button-layout` → (a) mutter's SSD frame and
  (b) gsd-xsettings → XSETTINGS `Gtk/DecorationLayout` → GTK `gtk-decoration-layout` →
  headerbar buttons. Neither (a) nor (b) exists on this machine (verified locally: `pgrep -f xsettings`
  shows no XSETTINGS daemon running; `gsettings get org.gnome.desktop.wm.preferences button-layout`
  returns `'appmenu:'` while buttons are unaffected).

### 2. The client-side mechanism that works regardless of compositor: `gtk-decoration-layout`

- **GTK3 `GtkHeaderBar`**: `_gtk_header_bar_update_window_buttons()` does
  `g_object_get (gtk_widget_get_settings (widget), "gtk-decoration-layout", &layout_desc, NULL)`,
  splits on `:`/`,`, and only creates a `close` button when the token `close` is present (and the
  window is deletable). The per-widget `GtkHeaderBar:decoration-layout` property overrides the
  setting when set
  ([gtkheaderbar.c, gtk-3-24](https://raw.githubusercontent.com/GNOME/gtk/gtk-3-24/gtk/gtkheaderbar.c);
  property docs in [gtksettings.c](https://raw.githubusercontent.com/GNOME/gtk/gtk-3-24/gtk/gtksettings.c)).
- **GTK4 `GtkWindowControls`** (the widget that actually renders the buttons inside
  `GtkHeaderBar`): `get_layout()` uses the widget's `decoration-layout` property if set, else
  `g_object_get (gtk_widget_get_settings (widget), "gtk-decoration-layout", ...)`. An empty or
  NULL layout ⇒ `set_empty(TRUE)` ⇒ no buttons are created at all. On `root()` it connects to
  `notify::gtk-decoration-layout` on GtkSettings, so it follows the setting exactly.
  Recognized tokens: `icon`, `minimize`, `maximize`, `close` (no `menu` in GTK4)
  ([gtkwindowcontrols.c, gtk main](https://raw.githubusercontent.com/GNOME/gtk/main/gtk/gtkwindowcontrols.c)).
  `GtkHeaderBar` hosts `windowcontrols.start` / `windowcontrols.end` nodes
  ([Gtk.HeaderBar docs](https://docs.gtk.org/gtk4/class.HeaderBar.html)).
- **libadwaita `AdwHeaderBar`**: class docs say it "displays the window controls … according to
  the system layout", and its `decoration-layout` property docs say: "If this property is not set,
  the `Gtk.Settings:gtk-decoration-layout` setting is used." Internally it creates
  `GtkWindowControls` and binds their `empty` property to visibility, so an empty layout hides
  the whole controls box. It never reads `org.gnome.desktop.wm.preferences`
  ([adw-header-bar.c, libadwaita main](https://raw.githubusercontent.com/GNOME/libadwaita/main/src/adw-header-bar.c);
  rendered docs: [Adw.HeaderBar](https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/class.HeaderBar.html)).
- **Precedence (highest first)**:
  1. App-set widget property (`AdwHeaderBar:decoration-layout` / `GtkHeaderBar:decoration-layout`
     / `GtkWindowControls:decoration-layout`) — app-side only, users can't touch it
     (both files above, property docs).
  2. `GtkSettings:gtk-decoration-layout` — from an XSETTINGS manager if one runs (none here),
     else from `settings.ini`.
  3. Compiled default `"menu:minimize,maximize,close"`.
  The dconf key `org.gnome.desktop.wm.preferences button-layout` is **never** in this chain
  unless gsd-xsettings republishes it (see §1).
- **Values that hide the close button** (tokens are `icon|minimize|maximize,close`, `menu` in GTK3):
  - Keep minimize/maximize, drop close: `gtk-decoration-layout=:minimize,maximize`
    (empty start side before `:`; works in GTK3 and GTK4).
  - Remove **all** window controls: `gtk-decoration-layout=` (empty string). GTK4's
    `get_layout()` returns NULL on empty ⇒ controls report `empty` and Adw hides them;
    GTK3's token loop creates nothing for an empty layout.
  - `menu` alone also ends up with no visible buttons in practice (GTK3 only shows `menu` if an
    app menu exists; GTK4 doesn't recognize the token at all).
- **Arch Wiki secondary confirmation**: "Hide CSD buttons … To remove the client-side
  decorations minimize and maximize buttons from gtk3 windows: `gtk-decoration-layout=menu:close`"
  ([ArchWiki: GTK § Hide CSD buttons](https://wiki.archlinux.org/title/GTK)).
- **Wayland caveat that does *not* apply to this key**: on the Wayland backend GTK3 takes keys
  belonging to the `org.gnome.desktop.interface` schema from GSettings instead of `settings.ini`
  — "This only applies for settings that belong to `org.gnome.desktop.interface`. Some settings …
  are still read from your `settings.ini`"
  ([sway wiki: GTK 3 settings on Wayland](https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland),
  [ArchWiki: GTK § GDK backends](https://wiki.archlinux.org/title/GTK)). `gtk-decoration-layout`
  is not in that schema (its dconf counterpart lives in `wm.preferences` and only reaches GTK via
  XSETTINGS), so **`settings.ini` is the source of this key on this machine**.
- Settings files: `~/.config/gtk-3.0/settings.ini` (existing, currently has **no**
  `gtk-decoration-layout` line) and `~/.config/gtk-4.0/settings.ini` (**does not exist yet** —
  must be created with a `[Settings]` section). Only newly started apps pick up `settings.ini`
  changes ([ArchWiki: GTK § Configuration note](https://wiki.archlinux.org/title/GTK)).

### 3. CSS approaches — what CSS can and cannot do

- GTK3 title buttons carry the style classes `titlebutton` + `close`/`minimize`/`maximize`
  ([gtkheaderbar.c](https://raw.githubusercontent.com/GNOME/gtk/gtk-3-24/gtk/gtkheaderbar.c));
  GTK4 controls are `windowcontrols` containing `button.minimize` / `button.maximize` /
  `button.close` ([gtkwindowcontrols.c docs](https://raw.githubusercontent.com/GNOME/gtk/main/gtk/gtkwindowcontrols.c));
  AdwHeaderBar's node tree is documented as `headerbar → windowhandle → box → … → windowcontrols`
  ([adw-header-bar.c docs](https://raw.githubusercontent.com/GNOME/libadwaita/main/src/adw-header-bar.c)).
- **CSS cannot remove a button from the layout.** The complete list of supported GTK CSS
  properties contains **no `display`, no `visibility`, no `width`/`height`** — only
  `min-width`/`min-height`, `margin`, `padding`, `border*`, `opacity`, `background*`, `transform`,
  `-gtk-icon-*`, etc.
  ([GTK3 CSS properties](https://docs.gtk.org/gtk3/css-properties.html),
  [GTK4 CSS properties](https://docs.gtk.org/gtk4/css-properties.html)).
  So a CSS rule can at best shrink/fade the button while it stays in the layout and keeps
  receiving clicks — there is no primary-source-supported CSS rule that truly hides it, and no
  evidence was found (GTK/libadwaita issue trackers surfaced nothing) that libadwaita enforces a
  hard minimum size you couldn't override — the real point is CSS is the wrong lever: the
  supported removal path (`gtk-decoration-layout`) never creates the button at all (GTK3) or
  makes the controls report `empty` so the container is hidden (GTK4/Adw).
- Best-effort, unverified CSS (visual only, button remains clickable; use only as last resort for
  things the layout setting can't reach, e.g. AdwDialog close buttons):
  ```css
  /* ~/.config/gtk-4.0/gtk.css  and  ~/.config/gtk-3.0/gtk.css */
  windowcontrols button.close,
  headerbar .titlebutton.close {
    min-width: 0; min-height: 0;
    padding: 0; margin: 0;
    border: none; background-image: none;
    opacity: 0;
  }
  ```
  Treat this as unverified; the settings approach should make it unnecessary for normal windows.

### 4. libadwaita specifics

- `AdwHeaderBar` exposes `show-start-title-buttons` / `show-end-title-buttons` /
  `decoration-layout` — **widget properties set by the application** (XML/code). There is no
  user-side dconf override: the class installs only these 7 properties and none is backed by a
  GSettings key; libadwaita ships no `org.gnome.adw.*` schema key for title buttons
  (property list in [adw-header-bar.c](https://raw.githubusercontent.com/GNOME/libadwaita/main/src/adw-header-bar.c)).
  User-side control comes solely through `GtkSettings:gtk-decoration-layout` (i.e.
  `~/.config/gtk-4.0/settings.ini` on this machine).
- **Exception**: "When placed in a [Adw]Dialog, it will only show a close button, regardless of
  the system button layout" ([Adw.HeaderBar docs](https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/class.HeaderBar.html))
  — dialog close buttons ignore `gtk-decoration-layout`.

### 5. Server-side decoration side: is the X drawn by mangowm?

- mango is "a Wayland compositor based on dwl", built on wlroots
  ([mangowm docs](https://mangowm.github.io/docs/), acknowledged wlroots/dwl/sway sources).
- **mango does not implement the xdg-decoration protocol at all.** Its entire
  `src/ext-protocol/` directory is: `ext-workspace`, `foreign-toplevel`, `hdr`, `tearing`,
  `text-input`, `xdg-activation`, `xdg-output` (verified against the source tree
  [github.com/mangowm/mango](https://github.com/mangowm/mango) and
  [ext-protocol/all.h](https://raw.githubusercontent.com/mangowm/mango/main/include/mango/ext-protocol/all.h)).
  There is no decoration manager, so the compositor never draws titlebars or window buttons,
  and no mango config option exists for window-control buttons (config docs cover borders,
  corner radius, blur — visuals, not buttons: [docs/visuals](https://mangowm.github.io/docs/visuals/effects)).
- Consequently, on this setup the X button is **drawn by GTK itself (CSD)**. GTK always uses
  client-side decorations for windows with a custom titlebar widget regardless of what the WM
  offers: "`CSD` … default 1. If changed to 0, this disables the default use of client-side
  decorations … making the window manager responsible … **CSD is always used for windows with a
  custom titlebar widget set**"
  ([GTK4 running docs § GTK_CSD](https://docs.gtk.org/gtk4/running.html)).
  Removing it must therefore happen inside GTK/libadwaita — the compositor cannot (and on this
  machine does not draw buttons that could be "removed").

## Why `gsettings … button-layout` is ineffective here

1. The key is only consumed by (a) **mutter** for its own frame layout
   ([prefs.c](https://raw.githubusercontent.com/GNOME/mutter/main/src/core/prefs.c)) and
   (b) **gnome-settings-daemon's xsettings plugin**, which republishes it as the XSETTINGS
   property `Gtk/DecorationLayout`
   ([gsd-xsettings-manager.c](https://raw.githubusercontent.com/GNOME/gnome-settings-daemon/master/plugins/xsettings/gsd-xsettings-manager.c)).
2. mangowm runs neither mutter nor gsd-xsettings (locally verified: no XSETTINGS daemon
   processes). On Wayland GTK also has no X11/XSETTINGS fallback for this key, and
   `gtk-decoration-layout` is not in the `org.gnome.desktop.interface` schema that GTK3 reads
   from GSettings on Wayland ([sway wiki](https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland)).
3. GTK3 `GtkHeaderBar`, GTK4 `GtkWindowControls`, and libadwaita `AdwHeaderBar` all read only
   `GtkSettings:gtk-decoration-layout` (sources above). On this machine that value comes from
   `settings.ini` only — which currently doesn't set it (verified: `~/.config/gtk-3.0/settings.ini`
   has no such line; `~/.config/gtk-4.0/settings.ini` doesn't exist), so everyone falls back to
   the compiled default `menu:minimize,maximize,close` and the X stays.
4. Net effect: writing the dconf key changes a value nothing on the system reads.

## Ranked fix steps for this machine

**1st — set `gtk-decoration-layout` in both settings.ini files (client-side, compositor-agnostic):**

- `~/.config/gtk-3.0/settings.ini` (append under the existing `[Settings]` section):
  ```ini
  [Settings]
  gtk-decoration-layout=:minimize,maximize
  ```
  …to keep minimize/maximize but drop **close**. Use `gtk-decoration-layout=` (empty) instead to
  remove **all** title buttons.
- `~/.config/gtk-4.0/settings.ini` (**create it**; it doesn't exist):
  ```ini
  [Settings]
  gtk-decoration-layout=:minimize,maximize
  ```
- This covers plain GTK3 headerbars, GTK4 `GtkHeaderBar`, and libadwaita `AdwHeaderBar`
  (via GtkSettings → GtkWindowControls), because on this machine `settings.ini` is the only
  live source for that setting.
- **Verify**: restart apps (settings.ini is read at startup): `nautilus` (GTK4/libadwaita),
  `gtk3-demo` / `gtk4-demo` / `adwaita-demo` if installed, plus daily apps (Files, Text Editor).
  Expect the X to be gone while min/max remain (or everything gone with the empty value).
  Live check: `GTK_DEBUG=interactive` inspector → `windowcontrols` node has no `button.close`,
  or simply look at the headerbar.

**2nd — don't run an XSETTINGS daemon that publishes `Gtk/DecorationLayout`:**
none is running now (verified). If you ever add `xsettingsd`/gnome-settings-daemon, configure
its `Gtk/DecorationLayout` consistently or it will override `settings.ini` for X11/XWayland GTK
apps (GTK3 GtkSettings docs: XSETTINGS manager takes over on X).

**3rd — per-app escape hatches:**
- `GTK_CSD=0` for stubborn **non-headerbar** GTK windows: it hands decoration to the WM
  ([GTK4 running docs](https://docs.gtk.org/gtk4/running.html)); since mango has no
  xdg-decoration, GTK then draws no frame/titlebar at all for those windows (mango's own
  border remains). It does **not** affect headerbar windows (CSD is forced for custom
  titlebars). Test per app, e.g. `GTK_CSD=0 gtk3-demo`.
- Apps that hardcode `AdwHeaderBar:decoration-layout` / `GtkHeaderBar:decoration-layout`
  override the user setting (property docs in adw-header-bar.c / gtkheaderbar.c) — only the
  app can be fixed (or patched). `AdwDialog` headerbars always show close (Adw docs above).

**4th — CSS only as a last-resort visual patch** (see §3 snippet): unverified, keeps an
invisible but clickable button; not needed if step 1 works.

## Caveats / unknowns

- **AdwDialog close buttons ignore the layout** ("only show a close button, regardless of the
  system button layout", Adw.HeaderBar docs). Only CSS or app-side changes can affect them.
- **App-set `decoration-layout` properties win** over your settings.ini (GTK3/GTK4/Adw
  property docs) — such apps are unaffected by step 1.
- **Electron/Chromium apps** draw their own titlebars (not GTK) — not verified against primary
  Electron sources in this research; expect `gtk-decoration-layout` to have no effect there.
- **Qt apps** are out of scope (different toolkit and configuration path entirely).
- Non-headerbar (traditional) GTK3 CSD windows: ArchWiki documents `gtk-decoration-layout` as
  removing CSD min/max buttons for "gtk3 windows" generally, so step 1 should cover them too,
  but this was not separately verified against gtkwindow.c.
- GTK4 `settings.ini` applies only "in the absence of these sharing mechanisms" (portal /
  XSettings) per Gtk.Settings docs; on this machine no portal/XSETTINGS provider for this key
  was found (no XSETTINGS daemon running; mango's portal setup doesn't publish
  `gtk-decoration-layout`). If a settings portal ever supplied it, portal values would take
  precedence over `settings.ini` defaults.
- Did not find any GTK/libadwaita upstream issue offering a supported CSS way to hide title
  buttons; absence-of-evidence only — the property lists are the stronger citation that CSS
  has no removal mechanism.
- Closing windows after hiding X: rely on your mangowm kill binding (dwl-style default is
  `Super+Q`) or `Alt+F4`-equivalent per your config.
