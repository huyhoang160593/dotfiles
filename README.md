# Dotfiles — CachyOS + chezmoi Setup Notes

## Prerequisites (install in order)
1. CachyOS (see CachyOS Notes below)
2. `fish` + `chezmoi` — shell & dotfile manager
3. Apply chezmoi: `chezmoi init --apply huyhoang160593/dotfiles`
4. Post-install fixes (see sections below)

---

## CachyOS Install Notes

### Avoid CachyOS fish config
- **Why**: Conflicts with chezmoi-managed `config.fish`, installs an unwanted custom prompt, and defines abbreviations/functions that contradict the intended design.
- **Fix**: Don't select the CachyOS fish config option during install.

### Window Manager: mangowm
- **Selected**: mangowm
- **Deselected**: ❌ SDDM (login manager) — use Noctalia Greeter instead for visual consistency
- **Fix after install**: Edit `~/.config/mango/cfg/env.conf` to set `QT_QPA_PLATFORMTHEME=qt6ct` and `QT_QPA_PLATFORMTHEME_QT6=qt6ct`

### Noctilia Config Fixes
- **Issue**: Noctalia greeter fails or validation shows warnings.
- **Fix**: 
  1. Run `noctalia-validate-config ~/.config/noctalia/`
  2. Fix invalid entries in `~/.config/noctalia/config.yaml`
  3. Ensure file perms: `chmod 644 ~/.config/noctalia/*`

### Vietnamese Input
- Install `fcitx5-lotus`
- Set default IM to `lotus` with `Alt+Space` toggle in `~/.config/fcitx5/config`

---

## Tool Stack

| Category | Tool | Note / Fix |
|---|---|---|
| Terminal | Ghostty (replaces Alacritty) | Minimal config: font, cursor style |
| Browser | Helium (replaces Firefox) | Runs as AppImage managed by AppManager |
| Shell | fish | Main shell; all functions written for fish, not bash |
| Prompt | Starship + Stella (theme mgr) | Rose-pine palette; apply with `stellua` |
| WM | mangowm | Wayland compositor; config in `~/.config/mango/cfg/` |
| Desktop Shell | Noctalia | Bar, panel, launcher, notifications, lock screen |
| Greeter | Noctalia Greeter | Login screen (not SDDM) |
| TUI Dashboard | Fresh | Terminal dashboard |
| Session Mgmt | Zellij | Tabs, panes, layouts |
| AI | Ante | Lightweight, fewer errors than Claude Code/Codex |
| AppImage Mgr | AppManager | Use `appimage_update_icon` to fix icon issues |
| CLI Utils | fzf, zoxide, eza, tealdeer, bat | Fuzzy finder, dir jumper, ls replacement, tldr, cat replacement |
| Web Sync | Koonde + Proton Pass | Bookmarks, passwords |
| Firewall | ufw | Open port for LocalSend (TODO below) |

---

## Known Issues & Fixes

### Dolphin won't open files
- **Issue**: Dolphin reports "no application available" for most file types.
- **Root cause**: Missing XDG portal configuration after removing Alacrity/Ghostty as default terminal.
- **Fix**:
  ```bash
  mkdir -p ~/.config/xdg-desktop-portal/
  echo "default-terminal=ghostty.desktop" > ~/.config/xdg-desktop-portal/defaults
  pkill xdg-desktop-portal; pkill dolphin
  ```

### AppImage icons break
- **Issue**: Icons don't show in launcher/desktop menus after AppManager integration.
- **Root cause**: Icons placed in wrong hicolor directory; GTK/desktop caches not refreshed.
- **Fix**: Run the fish function `appimage_update_icon` manually:
  ```fish
  appimage_update_icon
  ```
  Or it runs automatically when a new AppImage is installed via AppManager.

### Starship shows default prompt
- **Issue**: Starship prompt not styled with stella theme.
- **Fix**:
  ```fish
  stella apply rose-pine@1.0  # or your theme
  exec fish  # reload
  ```

---

## Environment Variables Checklist
- [ ] `QT_QPA_PLATFORMTHEME=qt6ct` in mangowm env.conf
- [ ] `QT_QPA_PLATFORMTHEME_QT6=qt6ct` in mangowm env.conf
- [ ] `GTK_THEME=Noctalia` (if applicable)
- [ ] `XDG_CURRENT_DESKTOP` set correctly for portals

---

## TODO / Backlog
- [ ] ✅ Write `CONTEXT.md` glossary
- [ ] ✅ Write `docs/adr/0001-chezmoi-fish-mangowm-on-cachyos.md`
- [ ] ⬜ Script: `list-packages.fish` to export required packages for fresh installs
- [ ] ⬜ Document ufw firewall rule for LocalSend:
  ```bash
  ufw allow from 192.168.0.0/16 to any port 8335 comment 'LocalSend'
  ```
- [ ] ⬜ Add `notes/fish-config-best-practices.md` (research note)
- [ ] ⬜ Create `notes/cachyos-post-install-checklist.md` — step-by-step verify list

---

See also: [CONTEXT.md](CONTEXT.md), [docs/adr](docs/adr/)
