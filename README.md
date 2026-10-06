# Dotfiles — Thiết lập desktop mangowm bằng chezmoi

Repo này dùng chezmoi quản lý dotfile và thiết lập environment trên CachyOS + mangowm (Wayland compositor) + Noctalia (desktop shell).

## Yêu cầu cài đặt theo thứ tự
1. CachyOS (xem ghi chú bên dưới)
2. `fish` + `chezmoi` — shell & quản lý dotfile
3. Đặt tên & email git (dùng email private để tránh lộ):
   ```bash
   git config --global user.name "The99sPuppycat"
   git config --global user.email "41776348+huyhoang160593@users.noreply.github.com"
   ```
4. Áp dụng chezmoi: `chezmoi init --apply huyhoang160593/dotfiles`
5. Các bước sửa sau cài đặt (xem từng phần bên dưới)

---

## Cẩm nang chezmoi

| Thao tác | Lệnh |
|---|---|
| Khởi tạo & áp dụng | `chezmoi init --apply huyhoang160593/dotfiles` |
| Sync sau khi sửa file nguồn | `chezmoi apply` |
| Xem trước thay đổi | `chezmoi diff` |
| Xem file nào chezmoi quản lý | `chezmoi managed` |
| Chỉnh sửa file chezmoi quản lý | `chezmoi edit <file>` |
| Thêm file mới vào repo | `chezmoi add <file>` |
| Gỡ file khỏi chezmoi | `chezmoi forget <file>` |
| Check status | `chezmoi status` |
| Push thay đổi lên repo | `chezmoi cd && git add -A && git commit -m "..." && git push` |

### Viết template chezmoi đúng cách

Các file chezmoi (`.chezmoiignore`, `.chezmoiignore.tmpl`) đều được xử lý như Go template. Tham khảo: [chezmoi docs — special files](https://www.chezmoi.io/reference/special-files/)

**`.chezmoiignore`** — danh sách file/folder không đồng bộ ra home:
- Pattern so sánh với **đường dẫn đích** (`~/docs`), không phải đường dẫn nguồn
- Go template chỉ cần dùng khi cần điều kiện (ví dụ: ignore theo hệ điều hành, theo phần mềm đã cài...)
- Nên dùng `#` cho comment trong `.chezmoiignore` (an toàn, không gây lỗi trim)
- Kiểm tra kết quả render: `cat .chezmoiignore.tmpl | chezmoi execute-template`
- Xem danh sách file bị bỏ qua: `chezmoi ignored`

**Secrets — `~/.ante/auth`** (đã ignore trong `.chezmoiignore.tmpl`):
- Thư mục này **không sync** qua chezmoi — mỗi máy tự tạo riêng
- Chứa `api_keys.json` lưu API key để Ante gọi AI provider (OpenAI, Anthropic...)
- Format: `{ "openai": "sk-...", "anthropic": "sk-ant-..." }`

**Secrets — `~/.config/opencode/service.json`** (không đưa vào chezmoi source):
- File này **không sync** — mỗi máy giữ riêng
- Chứa `password` của background service OpenCode

**Mẹo viết Go template chezmoi (áp dụng cho tất cả `.tmpl`):**
- `{{- ... -}}` xóa khoảng trắng 2 đầu dòng — useful cho code inline, nhưng **cẩn thận**: nó cũng xóa newline, dễ làm 2 dòng content dính vào nhau
- Comment: dùng `#` cho tất cả file template — đơn giản, an toàn, không gây lỗi trim
- Các hàm template hay dùng: `output`, `trim`, `eq`, `ne`, `not`, `if/else/end` — xem thêm: [template functions](https://www.chezmoi.io/reference/templates/functions/)

---

## Ghi chú cài đặt CachyOS

### Không dùng cachyos-fish-config
- **Lý do**: Gói `cachyos-fish-config` xung đột với `config.fish` do chezmoi quản lý, cài thêm prompt không mong muốn, và định nghĩa các abbreviation/function mâu thuẫn với thiết kế dự kiến.
- **Cách sửa**: Bỏ chọn gói `cachyos-fish-config` khi cài đặt CachyOS (hoặc gỡ nếu đã cài).

### Window Manager: mangowm
- **Đã chọn**: mangowm
- **Đã bỏ chọn**: ❌ SDDM (login manager) — dùng Noctalia Greeter thay thế để đồng bộ giao diện
- **Env vars**: QT_QPA_PLATFORMTHEME, QT_QPA_PLATFORMTHEME_QT6, PATH, BROWSER — đã cấu hình sẵn trong `~/.config/mango/cfg/env.conf` (chezmoi sync). Một số env (như `BROWSER`) cần set ở cả env.conf lẫn `config.fish` — xem mục "Biến môi trường" bên dưới.

### Autostart khi login (mango autostart.conf)
- File: `~/.config/mango/cfg/autostart.conf` (chezmoi sync), chạy lúc compositor khởi động.
- **EasyEffects phải tự chạy khi login** (service mode: chạy nền, không mở cửa sổ) — dùng để chỉnh âm loa laptop (to, rõ hơn); thiếu thì âm quay về mặc định cho tới khi tự mở app.
- **Lưu ý**: EasyEffects có autostart riêng qua `~/.config/autostart/com.github.wwmm.easyeffects.desktop` (systemd unit `app-...@autostart.service`) — file này từng biến mất nên app không tự chạy; hiện dựa vào mango `autostart.conf`, không cần file đó.
- Sửa `autostart.conf` xong cần **re-login** (exec-once chỉ chạy lúc compositor start).

### EasyEffects — preset
- EasyEffects cài mới **không kèm sẵn preset nào** (mục Presets trống) — không phải lỗi máy: preset do người dùng cộng đồng tạo, upstream chỉ tổng hợp link tại [Community presets wiki](https://github.com/wwmm/easyeffects/wiki/Community-presets) (README upstream cũng trỏ đúng vào wiki này).
- Nguồn preset cộng đồng (tổng hợp, có link tải): https://github.com/wwmm/easyeffects/wiki/Community-presets
- Đang dùng: https://github.com/JackHack96/EasyEffects-Presets (link trong wiki trên) — preset output nằm tại `~/.local/share/easyeffects/output/`.

### Validate Config Noctalia
- Config: `~/.config/noctalia/*.toml` (định dạng TOML)
- Validate: `noctalia config validate`
- Docs: https://docs.noctalia.dev/noctalia/configuration/

### Plugin Noctalia đang dùng
Nguồn plugin (khai báo trong `~/.config/noctalia/config.toml`, mục `[plugins]`):
- `official`: https://github.com/noctalia-dev/official-plugins
- `community`: https://github.com/noctalia-dev/community-plugins

| Plugin ID | Nguồn | Công dụng | Vị trí trong config |
|---|---|---|---|
| `noctalia/screen_recorder` | official | Ghi màn hình bằng `gpu-screen-recorder` + replay buffer. Widget `recorder`: click trái = bật/tắt ghi, click phải = bắt đầu/dừng replay buffer, click giữa = lưu replay. Cần cài `gpu-screen-recorder` | widget `recorder` ở nhóm `end` của bar; setting `restore_portal = false` |
| `dotnetrob/cat` | community | Mèo animation trong bar phản ánh tải CPU: ngủ khi idle, đi bộ khi CPU > 15% (`walk_threshold`), chạy khi > 60% (`run_threshold`); màu theo theme. Click vào widget hiện panel CPU % | widget `cat` ở nhóm `center` của bar, `cat_size = 34` |
| `nightwatch75/dns-switcher` | community | Chuyển DNS hệ thống (Google, Cloudflare, OpenDNS, AdGuard, Quad9 hoặc tối đa 5 server custom) không ngắt kết nối, chạy qua `nmcli`; panel có sẵn test DNS lookup (`dig`/`nslookup`). Click trái = mở panel, click phải = reset về DNS ISP, scroll = chuyển provider | widget `dns_switcher_2` ở nhóm `start` của bar |
| `vn1k/cursor` | community | Đổi cursor theme cho compositor + GTK + Qt/XWayland cùng lúc; import pack Windows, build từ PNG. Không có bar widget — thêm lên bar bằng `custom_button` với custom command (picker Home Shortcuts của Control Center không liệt kê shortcut plugin). Deps full experience: `check_cursor_stack`. Mango: cursor do `cursor.conf` own (đã xóa khỏi `appearance.conf`); `config.conf` là template `homeDir` cho portable đa username; `cursor.conf` + `90-xcursor.conf` + `.icons/default` do plugin own, không đưa vào chezmoi | custom button `Cursor_Plugin` ở nhóm `end` của bar (code mẫu bên dưới) |

Custom button mở panel Cursor (`config.toml`):

```toml
[widget.Cursor_Plugin]
glyph = "pointer-cog"
type = "custom_button"

    [widget.Cursor_Plugin.actions]
    left = "exec noctalia msg panel-toggle vn1k/cursor:manager"
```

Nguồn tham khảo plugin Cursor:
- [Cursor plugin page](https://noctalia.dev/plugins/community/cursor) (entries `manager`/`shortcut`, deps full experience)
- [Custom cursor](https://vsthemes.org/en/cursors/) — nguồn theme cursor custom (tải về rồi `Install theme` trong panel; theme file nằm local `~/.local/share/icons/`, không sync qua chezmoi — máy mới tự cài + Apply tại chỗ)
- [Control Center Shortcuts docs](https://docs.noctalia.dev/noctalia/control-center/shortcuts/) (chỉ liệt kê built-in — plugin shortcut phải thêm tay via TOML)
- [community-plugins#880](https://github.com/noctalia-dev/community-plugins/issues/880) (panel-only plugins thiếu `[[widget]]`, gồm `vn1k/cursor`)

### Nhập liệu tiếng Việt
- Cài `fcitx5-lotus`
- Xem hướng dẫn cài đặt chi tiết cho từng hệ điều hành tại: https://lotusinputmethod.github.io/#installation
- Cài xong, set default IM thành `lotus` với toggle `Alt+Space` trong `~/.config/fcitx5/config`

---

## Bộ công cụ

| Hạng mục | Công cụ | Mô tả | Ghi chú / Fix |
|---|---|---|---|
| Terminal | Ghostty | Terminal emulator nhanh, hỗ trợ GPU rendering, minimalist UI | Thay thế Alacritty |
| Trình duyệt | Helium | Trình duyệt nhẹ, chạy dạng AppImage | Quản lý bởi AppManager; cần gnome-keyring (Secret Service) nếu không reboot là mất login — xem sự cố bên dưới |
| Shell | fish | Shell chính; tất cả function viết cho fish, không phải bash | |
| Prompt | Starship + Stellar (quản lý theme) | Prompt đa nền tảng; Stellar tự sở hữu `~/.config/starship.toml` | Theme `presets/rose-pine-moon@1.0`, áp dụng thủ công — xem mục "Starship hiển thị prompt mặc định" |
| WM | mangowm | Wayland compositor | Config trong `~/.config/mango/cfg/` |
| Desktop Shell | Noctalia | Thanh trạng thái, panel, launcher, thông báo, màn hình khóa | |
| Âm thanh | EasyEffects | Chỉnh âm loa laptop: EQ/compressor cho âm to, rõ hơn (PipeWire) | Autostart service-mode + preset cộng đồng — xem 2 mục EasyEffects bên dưới |
| Greeter | Noctalia Greeter | Màn hình đăng nhập (không dùng SDDM) | |
| Dashboard TUI | Fresh | Dashboard terminal | |
| Quản lý session | Zellij | Tab, pane, layout cho terminal | |
| AI | Ante, OpenCode, Bladebro | Ante lightweight; OpenCode là terminal agent; Bladebro là browser cho AI agent (MCP 5 tools) | Bladebro cài bằng `npm install -g bladebro`, lái Helium qua `CHROME_PATH`; MCP `opencode.json` do chezmoi sync (template `lookPath`, máy không có Helium thì bỏ block env) |
| Quản lý AppImage | AppManager | Cài đặt và quản lý AppImage | Dùng `appimage_update_icon` để sửa icon |
| Quản lý runtime | mise | Quản lý phiên bản runtime (node, python, go...) theo project | Activate trong `config.fish` có guard `type -q` — xem mục mise bên dưới |
| CLI tiện ích | fzf, zoxide, eza, tealdeer, bat | Fuzzy finder, nhảy thư mục, ls replacement, tldr, cat replacement | eza dùng `--icons=auto` |
| System info | fastfetch | Hiển thị thông tin hệ thống khi mở shell | Preset `examples/12.jsonc` |
| Git TUI | lazygit | Giao diện terminal cho git | Commit, diff, stash, merge trực quan |
| Đồng bộ web | Koonde + Proton Pass | Bookmark, mật khẩu | |
| Firewall | ufw | Mở port cho LocalSend | Xem phần ufw bên dưới |

### mise — quản lý runtime

- **Cài đặt**: `curl https://mise.run | sh` → cài vào `~/.local/bin/mise` (đã có trong PATH).
- **Kích hoạt trong fish** (`~/.config/fish/config.fish`, chezmoi sync) — guard `type -q` nên môi trường chưa cài mise **không bị lỗi** khi mở shell:
  ```fish
  if type -q mise
      mise activate fish | source
  end
  ```
- **Kiểm tra**: `mise -v` hoặc chạy `check_tools` (mise nằm trong danh sách tool bắt buộc).
- **Lưu ý**: `mise activate` chỉ hiệu lực trong shell interactive; script non-interactive cần dùng `mise exec --` hoặc shims (`mise activate fish --shims`).

---

## Các sự cố đã biết & Cách sửa

### Mất boot option Limine trong BIOS (dual-boot với SSD ngoài)
- **Sự cố**: Dual-boot Windows (NVMe trong) + CachyOS (SSD ngoài USB — ESP `/dev/sda1` mount tại `/boot`, root `/dev/sda2`). Boot Windows khi SSD ngoài chưa cắm → firmware **xóa luôn boot entry Limine** trong NVRAM; cắm lại SSD ngoài vẫn mất, không hiện trong Boot options lẫn Boot Order.
- **Nguyên nhân**: Boot entry trỏ vào thiết bị vắng mặt lúc POST bị firmware gỡ (đặc biệt với ổ USB). File bootloader trên ESP vẫn còn nguyên — chỉ mất entry trong NVRAM.
- **Cách sửa** (boot bằng live ISO CachyOS):
  1. Boot CachyOS live ISO, kết nối mạng (cần pacman).
  2. Vào chroot:
     ```bash
     sudo su
     pacman -Sy cachy-chroot   # nếu ISO chưa có sẵn
     cachy-chroot
     ```
     `cachy-chroot` tự tìm phân vùng, mount root + mọi mountpoint trong `fstab` rồi chroot vào.
  3. Chọn đúng SSD ngoài khi nó liệt kê phân vùng (kiểm tra bằng `lsblk`: EFI `vfat` ~4G + root `btrfs`); khi hỏi phân vùng thêm thì nhập `/boot`.
  4. Trong chroot, cài lại Limine:
     ```bash
     limine-install
     ```
     (copy `limine_x64.efi` vào ESP và tự đăng ký lại boot entry NVRAM)
  5. Tạo lại boot entries kernel (chạy lại hook `limine-mkinitcpio`):
     ```bash
     pacman -Syu linux-cachyos linux-cachyos-headers
     ```
  6. `exit` → **shutdown hẳn** → cắm SSD ngoài → bật máy → vào BIOS xác nhận entry **Limine** đã trở lại và đứng đầu Boot Order.
- **Verify**: trong hệ thống chạy `efibootmgr -v` → thấy `Boot....* Limine ... \EFI\limine\limine_x64.efi`.
- **Bootloader khác** (theo [FAQ CachyOS — Bootloader Recovery](https://wiki.cachyos.org/cachyos_basic/faq)):

  | Bootloader | Lệnh sửa trong chroot (UEFI) |
  |---|---|
  | systemd-boot | `bootctl install` |
  | GRUB | `grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=cachyos` rồi `grub-mkconfig -o /boot/grub/grub.cfg` |

- **Phòng ngừa**:
  1. Firmware tự xóa boot entry nếu boot khi SSD ngoài chưa cắm — cắm lại sau đó vẫn mất.
  2. Luôn shutdown hẳn trước khi rút SSD ngoài (đừng để máy boot/POST khi SSD chưa cắm).
  3. Chạy `limine-install --fallback` một lần để ghi `\EFI\BOOT\BOOTX64.EFI` vào SSD ngoài — firmware thường boot được đường fallback này cả khi mất entry (đặc biệt với ổ USB).

### Dolphin không mở được file
- **Sự cố**: Dolphin báo "Terminal ghostty not found" khi mở file bằng terminal.
- **Nguyên nhân**: `ghostty` nằm trong `~/.local/bin/` nhưng PATH của KDE session không có thư mục này.
- **Cách sửa**: Thêm `~/.local/bin` vào PATH trong `~/.config/mango/cfg/env.conf`:
  ```
  env = PATH,~/.local/bin:~/.ante/bin:/usr/local/bin:/usr/bin
  ```
  File này do chezmoi quản lý, sẽ được sync đúng khi apply.
- **Quick hack** (nếu chưa muốn apply chezmoi): set `TerminalApplication` thành full path trong `kdeglobals`:
  ```
  TerminalApplication=/home/the99spuppycat/.local/bin/ghostty
  ```

### Qt app mở từ browser bị hỏng theme
- **Sự cố**: Mở Dolphin (hoặc Qt app khác) từ Helium/Chrome qua "download → truy cập thư mục", Dolphin hiện theme mặc định/fusion thay vì Noctalia.
- **Nguyên nhân**: Dolphin có background daemon (`plasma-dolphin.service`) do systemd user quản lý. Hệ thống `~/.config/environment.d/` **không được systemd đọc** vì MangoWM start sau khi systemd user instance đã chạy. Khi browser gọi DBus mở Dolphin, daemon thiếu `QT_QPA_PLATFORMTHEME` → render theme sai.
- **Cách sửa**: Đã fix bằng `exec-once = systemctl --user import-environment` trong `autostart.conf` (chezmoi sync). Lệnh này push env vars của MangoWM (bao gồm `QT_QPA_PLATFORMTHEME` từ `env.conf`) vào systemd user session mỗi lần login.
- **Quick fix** (session hiện tại):
  ```bash
  systemctl --user import-environment QT_QPA_PLATFORMTHEME QT_QPA_PLATFORMTHEME_QT6
  systemctl --user restart plasma-dolphin.service
  ```
- **Verify**: Kiểm tra Dolphin daemon có env chưa:
  ```bash
  cat /proc/$(pgrep -x dolphin)/environ | tr '\0' '\n' | grep QT
  ```

### Icon AppImage bị hỏng
- **Sự cố**: Icon không hiển thị trong launcher/menu desktop sau khi tích hợp AppManager.
- **Nguyên nhân**: Icon đặt sai thư mục hicolor (PNG lẻ ở `~/.local/share/icons/` thay vì `hicolor/256x256/apps/`, SVG lẻ như Vesktop thay vì `hicolor/scalable/apps/`); cache GTK/desktop chưa được làm mới.
- **Cách sửa**: Chạy function fish `appimage_update_icon`:
  ```fish
  appimage_update_icon
  ```
  Hoặc script tự chạy khi cài AppImage mới qua AppManager.

### Ẩn nút X (close) trên GTK apps — tại sao gsettings "không hiệu quả"
- **Sự cố**: Muốn ẩn window controls (nút X...) trên GTK apps trên mango (không có mutter); `gsettings set org.gnome.desktop.wm.preferences button-layout ...` không hiệu quả, settings.ini cũng không thấy tác dụng.
- **Nguyên nhân (3 lớp)**:
  1. **Ghostty AppImage (bản sharun) có file `.env` trong bundle set `GSETTINGS_BACKEND=keyfile`** → mọi `gsettings set` gõ từ terminal ghi vào `~/.config/glib-2.0/settings/keyfile`, trong khi portal/GTK đọc **dconf** → giá trị biến mất. Đây là lý do gsettings "không hiệu quả". (Ghostty upstream không làm gì sai — env nằm ở file `.env` của bundle đóng gói.)
  2. **GTK4 (libadwaita) đọc button-layout qua xdg-desktop-portal**, không phải mutter/XSETTINGS như thường nghĩ — portal thắng mọi settings.ini. Verify bằng `gdbus call ... org.freedesktop.portal.Settings.Read org.gnome.desktop.wm.preferences button-layout`.
  3. **GTK3** không có portal/XSETTINGS trên session này → **settings.ini là nguồn duy nhất** có tác dụng cho GtkHeaderBar GTK3.
- **Cách sửa (đã apply)**:
  - Ghi thẳng dconf: `GSETTINGS_BACKEND=dconf gsettings set org.gnome.desktop.wm.preferences button-layout ':'` (persist tại `~/.config/dconf/user` — **không** đưa file dconf vào chezmoi vì là binary DB ghi thường xuyên)
  - `~/.config/gtk-3.0/settings.ini` + `~/.config/gtk-4.0/settings.ini` (chezmoi sync): `gtk-decoration-layout=:` — GTK3 dùng chính, GTK4 làm fallback khi portal chết (đã verify: stop portal → `gtk4-query-settings` trả `":"`)
  - `config.fish`: `set -gx GSETTINGS_BACKEND dconf` (chèn sau lúc ghostty tiêm — win vì chạy sau spawn)
  - mango `env.conf`: `env = GSETTINGS_BACKEND,dconf` (phòng hờ cho app spawn từ session; cần re-login)
- **Verify**: portal Read trả `':'`; `gtk4-query-settings 2>&1 | grep decoration` = `":"` (khi portal tắt); mở Loupe không còn nút X.
- **Giới hạn**: nút đóng trong `AdwDialog` của libadwaita **luôn hiện** bất kể layout ("regardless of the system button layout") — không override được từ user side.
- Chi tiết: [docs/research/gtk-hide-close-button.md](docs/research/gtk-hide-close-button.md) — **lưu ý**: phần đầu research kết luận "chỉ mutter/ gsdxsettings đọc key nên gsettings vô dụng" đã bị bổ sung ở đây: GTK4 thực ra đọc qua portal, vấn đề thật là backend keyfile.

### Helium mất login sau reboot (thiếu Secret Service)
- **Sự cố**: Mỗi lần reboot phải login lại mọi web, nhưng bookmark/history/profile `Puppycat` vẫn còn.
- **Nguyên nhân**: Helium (Chromium, profile `~/.config/net.imput.helium/`) mã hóa cookie/password qua `os_crypt`, cần D-Bus `org.freedesktop.secrets`. Máy không có provider nào (gnome-keyring bị mask `-> /dev/null` + override `ExecStart=/bin/false` + autostart `Hidden=true`, kwallet không chạy) → `Local State` thiếu `os_crypt.encrypted_key` (`portal.prev_init_success=false`) → cookie cũ không giải mã được. Profile không bị xóa, không nằm trên tmpfs.
- **Cách sửa (đã apply)**:
  1. Gỡ mask user-level: xóa symlink `gnome-keyring-daemon.{service,socket} -> /dev/null`, 2 thư mục override `dbus-*/org.*secrets*.service.d`, 2 file autostart `gnome-keyring-*.desktop`; `systemctl --user enable --now gnome-keyring-daemon.socket`.
  2. Auto-unlock qua greetd (file ngoài chezmoi, sửa bằng sudo 1 lần):
     ```bash
     sudo tee -a /etc/pam.d/greetd >/dev/null <<'EOF'
     auth optional pam_gnome_keyring.so
     session optional pam_gnome_keyring.so auto_start
     EOF
     ```
  3. Mango `autostart.conf` (chezmoi sync): `exec-once = gnome-keyring-daemon --start --components=secrets,ssh,pkcs11 &` để daemon chạy ngay cả khi socket chưa trigger.
  4. Mật khẩu keyring `~/.local/share/keyrings/Default.keyring` phải trùng mật login; nếu lệch thì `rm` file đó cho tạo lại ở login tới, rồi mở Helium login lại 1 lần cuối để mã hóa lại cookie.
- **Verify**: `dbus-send ... ListNames | grep secrets` thấy `org.freedesktop.secrets`; `Local State` có `os_crypt.encrypted_key`; reboot không mất login nữa.
- Chi tiết: [ADR-0004](docs/adr/0004-helium-gnome-keyring-auto-unlock.md), thuật ngữ `Secret Service / gnome-keyring / os_crypt` trong [CONTEXT.md](CONTEXT.md).

### Starship hiển thị prompt mặc định
- **Sự cố**: Starship chưa được áp dụng theme stellar (máy mới, hoặc `~/.config/starship.toml` chưa tồn tại). Theme không do chezmoi quản lý — mỗi máy tự áp dụng (xem [ADR-0002](docs/adr/0002-stellar-tu-so-huu-starship-config.md)).
- **Cách sửa**:
  ```fish
  stellar apply presets/rose-pine-moon@1.0  # theme mặc định của setup này
  exec fish  # tải lại
  ```
- **Phát hiện sớm**: chạy `check_tools` — stellar cài rồi nhưng chưa apply theme sẽ được báo thiếu kèm đúng lệnh trên.

### Icon fcitx5 biến mất khỏi tray (vẫn gõ được)
- **Sự cố**: Khay `tray` trên bar không còn icon bàn phím fcitx5, nhưng `Alt+Space` vẫn chuyển được `keyboard-us`/`lotus`.
- **Nguyên nhân**: Race lúc login — `fcitx5 -d` (mango `exec-once`) chạy trước khi Noctalia đăng ký `StatusNotifierWatcher`, module `notificationitem` (OnDemand) không đăng ký item. `fcitx5-remote -r` (reload config) không đủ để kích lại.
- **Cách sửa** (restart process, ~2s mất gõ):
  ```bash
  fcitx5-remote -e; sleep 1; fcitx5 -d
  ```
  Xong bấm `Alt+Space` về lại `lotus` (restart reset về `keyboard-us`).
- **Verify**: item fcitx5 có mặt trong watcher (đăng ký dạng path `:1.xxx/StatusNotifierItem`, không cần bus name riêng):
  ```bash
  busctl --user get-property org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.kde.StatusNotifierWatcher RegisteredStatusNotifierItems
  fcitx5-remote -n  # lotus
  ```

### Template community mới thêm không render (set trùng scheme = no-op)
- **Sự cố**: Thêm id mới vào `theme.templates.community_ids` (vd `fcitx5`) rồi `color-scheme-set` lại đúng scheme đang dùng → template không render (không có `themes/noctalia/theme.conf`, `classicui.conf` chưa tạo).
- **Nguyên nhân**: Set trùng giá trị là no-op, Noctalia không render lại.
- **Cách sửa**: Toggle scheme đi-về để ép render (vd `builtin Noctalia` rồi về `wallpaper m3-fruit-salad`):
  ```bash
  noctalia msg color-scheme-set builtin Noctalia
  noctalia msg color-scheme-set wallpaper m3-fruit-salad
  ```
- **Verify**: `ls ~/.local/share/fcitx5/themes/noctalia/` có `theme.conf`; `chezmoi status` vẫn clean (render trùng nội dung).
- **Nguồn tham khảo**: [Template Reference](https://docs.noctalia.dev/noctalia/theming/templates/) (cú pháp template, hooks, render), [App Theming](https://docs.noctalia.dev/noctalia/theming/app-theming/) (áp màu Noctalia ra file config app)

### Icon trong app Qt (Fcitx5 Settings) chìm vào nền tối
- **Sự cố**: Nút OK/Apply/phím tắt trong `fcitx5-config-qt` có icon nhưng đen chìm vào nền tối; khung app (chữ/nền) vẫn đúng palette.
- **Nguyên nhân**: Template Noctalia `qt` chỉ render file **màu** (`qt6ct/colors/noctalia.conf`), không đụng `qt6ct.conf` — dòng `icon_theme=breeze` (glyph tối) gặp palette tối. App này là Qt6 nên chỉ đọc `qt6ct`.
- **Cách sửa**: `icon_theme=breeze` → `breeze-dark` trong `~/.config/qt6ct/qt6ct.conf`, tắt mở lại app (Qt đọc icon theme lúc start).
- **Sync**: file đã vào chezmoi dạng template (`homeDir` cho `color_scheme_path`, lược `[SettingsWindow]` geometry để khỏi nhiễu `chezmoi status`). Đổi sang light mode thì sửa ngược lại thành `breeze`.
- **Nguồn tham khảo**: [GTK and Qt Applications template](https://docs.noctalia.dev/noctalia/templates/official/gtk-qt/) (template `qt` chỉ render file màu `colors/noctalia.conf` — `qt6ct.conf` như `icon_theme` nằm ngoài phạm vi nó quản lý)

---

## Biến môi trường (mangowm env.conf)
Tất cả env vars được quản lý tại `~/.config/mango/cfg/env.conf` (chezmoi sync):
```
env = QT_QPA_PLATFORMTHEME,qt6ct
env = QT_QPA_PLATFORMTHEME_QT6,qt6ct
env = PATH,~/.local/bin:~/.ante/bin:/usr/local/bin:/usr/bin
env = BROWSER,helium
env = GSETTINGS_BACKEND,dconf
```
> **Lưu ý**: mangowm mở rộng `~` nhưng **không** mở rộng `$HOME`.

### Env cần set ở CẢ HAI nơi: mangowm session lẫn fish
Một số env vars quyết định cách **mở ứng dụng/link** (ví dụ `BROWSER`) nên được set ở cả `~/.config/mango/cfg/env.conf` **và** `~/.config/fish/config.fish`, vì hai môi trường này không thừa hưởng env của nhau:

- Chỉ set trong **fish** (`set -gx BROWSER helium`): biến chỉ có hiệu lực trong terminal — GUI apps do compositor spawn (Noctalia, launcher...) **không nhận được** → `xdg-open` fallback sang parse file `.desktop`, dễ fail âm thầm (vd: nút mở link trong Settings → Plugins của Noctalia không có phản hồi).
- Chỉ set trong **env.conf**: TTY/greeter session (không đi qua mangowm) không nhận được.

```
# ~/.config/mango/cfg/env.conf (chezmoi sync)
env = BROWSER,helium
```
```fish
# ~/.config/fish/config.fish (chezmoi sync)
set -gx BROWSER helium
```

Sau khi sửa env.conf cần **đăng xuất/đăng nhập lại** session (env chỉ nạp lúc compositor khởi động); sửa config.fish thì `exec fish` là đủ.

> Chi tiết case này: [docs/research/noctalia-plugin-link-opening.md](docs/research/noctalia-plugin-link-opening.md)

---

## Firewall — ufw cho LocalSend

LocalSend dùng port `53317` (TCP + UDP) để gửi/nhận file qua mạng local.

```bash
sudo ufw allow 53317
```

Sau khi thêm rule:
```bash
sudo ufw status verbose  # kiểm tra rule đã được thêm
```

---

## Phím tắt thường dùng

Toàn bộ bind nằm trong `~/.config/mango/cfg/keybinds.conf` (chezmoi sync) — xem đầy đủ tại https://mangowm.github.io/docs/bindings/keys. `Super` = phím Windows.

### Chụp màn hình & quay màn hình

| Phím | Chức năng | Ghi chú |
|---|---|---|
| `Super + P` | Chụp **vùng** (kéo chọn vùng) | Gọi `noctalia msg screenshot-region` |
| `Super + Shift + P` | Chụp **toàn màn hình** hiện tại | Gọi `noctalia msg screenshot-fullscreen` |
| `Super + Alt + P` | Chụp **toàn bộ mọi màn hình** | Gọi `noctalia msg screenshot-fullscreen all` |

**Quay màn hình**: không có phím tắt — dùng widget `recorder` trên thanh bar (plugin `noctalia/screen_recorder`): click trái = bật/tắt ghi, click phải = replay buffer, click giữa = lưu replay. Hoặc mở Control Center (`Super + S`) dùng shortcut recorder. File ghi vào `~/Videos/Recordings`.

### Ứng dụng & Noctalia

| Phím | Chức năng |
|---|---|
| `Super + Return` | Mở Ghostty (terminal) |
| `Super + E` | Mở Dolphin (file manager) |
| `Super + B` | Mở Helium (browser) |
| `Super + Space` | Mở Launcher |
| `Super + S` | Mở Control Center |
| `Super + Shift + S` | Mở Settings Noctalia |
| `Super + C` | Mở bảng Clipboard history |
| `Super + Shift + Q` | Bảng session (đăng xuất/tắt máy) |
| `Super + R` | Reload config mango |

### Cửa sổ & workspace

| Phím | Chức năng |
|---|---|
| `Super + Q` | Đóng cửa sổ hiện tại |
| `Super + Tab` | Chuyển focus giữa cửa sổ |
| `Super + V` | Toggle floating |
| `Super + F` | Toggle maximize |
| `Super + Shift + F` | Toggle fullscreen |
| `Alt + Tab` | Toggle overview |
| `Super + 1…9` | Chuyển workspace |
| `Super + Shift + 1…9` | Chuyển cửa sổ sang workspace khác |
| `Super + Z` | Toggle scratchpad |

---

## Fish custom functions

Các function fish do chezmoi quản lý, đặt tại `~/.config/fish/private_functions/`:

| Function | Mô tả | Cách dùng |
|---|---|---|
| `appimage_update_icon` | Di chuyển icon lẻ từ `~/.local/share/icons/` về đúng chỗ (PNG → `hicolor/256x256/apps/`, SVG như Vesktop → `hicolor/scalable/apps/`), cập nhật GTK icon cache & desktop database | `appimage_update_icon` |
| `check_tools` | Kiểm tra tất cả tool trong bộ công cụ đã cài đặt chưa, liệt kê cái còn thiếu | `check_tools` |
| `check_mango_stack` | Kiểm tra stack mango: portal package đã cài và service có chạy không | `check_mango_stack` |
| `check_cursor_stack` | Kiểm tra deps full experience của plugin Cursor vn1k/cursor (win2xcur, python-wand, imagemagick, zenity) | `check_cursor_stack` |
| `lazygit_generate_msg` | Wrapper cho script AI commit message, delegate tới `~/.local/bin/lazygit-generate-msg` | `lazygit_generate_msg [direct\|push\|clipboard\|undo]` |

### Per-system config (conf.d)

Fish source tất cả file `*.fish` trong `~/.config/fish/conf.d/` trước `config.fish`, chạy cho mọi shell (interactive + non-interactive). Repo có sẵn file mẫu:

```
~/.config/fish/conf.d/00_example_per_system_config.fish   ← template (chezmoi sync)
```

**Cách thêm config riêng cho máy:**
1. Copy file mẫu, đổi tên theo quy ước `NN_description.fish` (VD: `01_work_laptop.fish`)
2. File mới nằm ngoài repo → chezmoi bỏ qua, không ghi đè khi apply trên máy khác
3. Định groups: PATH, Env vars, Tool init (xem file mẫu)

---

## lazygit — AI Commit Message

Tích hợp Ante (AI agent) với lazygit để generate commit message từ staged diff.

### Cách dùng

Trong lazygit TUI, nhấn **`Ctrl+A`** để mở menu:

| Phím | Chế độ | Mô tả |
|------|--------|-------|
| `d` | Direct | Gen message → commit thẳng |
| `p` | Push | Gen message → commit → push lên remote |
| `c` | Clipboard | Gen message → copy vào clipboard (paste tay vào editor) |
| `u` | Undo | `git reset --soft HEAD~1` (giữ changes staged) |

### Cấu trúc file

```
~/.config/lazygit/config.yml          ← lazygit config (custom command menu)
~/.local/bin/lazygit-generate-msg     ← bash script (bridge logic)
~/.config/fish/functions/lazygit_generate_msg.fish  ← fish wrapper
```

### Cấu hình AI agent

Script hỗ trợ đổi AI agent qua environment variables:

```bash
AI_CMD="ante"                          # Tên command (default: ante)
AI_FLAGS="--no-skills --no-session-save --output-format json --tools ''"
AI_PROMPT_FLAG="-p"                    # Cờ truyền prompt
```

Ví dụ đổi sang tool khác:
```bash
export AI_CMD="claude"
export AI_FLAGS="--print"
export AI_PROMPT_FLAG=""
```

### Yêu cầu

- `jq` — parse JSON output từ Ante
- AI agent trong PATH (mặc định: `ante`)
- Clipboard tool cho chế độ copy: `wl-copy` (Wayland), `xclip` (X11), hoặc `pbcopy` (macOS)

### Limitations

- **Không thể mở editor từ custom command**: lazygit custom command không thể inject message vào commit editor. Dùng clipboard mode nếu muốn review trước khi commit.
- **Chỉ staged changes**: Script dùng `git diff --cached`. Phải stage file trước khi trigger.
- **`--tools ''`**: AI agent chạy mà không có tool nào — chỉ đọc diff từ stdin và output text.

### Nguồn tham khảo

- [lazygit Custom Commands](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Command_Keybindings.md)
- [lazygit Custom Commands Compendium](https://github.com/jesseduffield/lazygit/wiki/Custom-Commands-Compendium)
- [Discussion #4100](https://github.com/jesseduffield/lazygit/discussions/4100): shell-ask integration
- [Discussion #4666](https://github.com/jesseduffield/lazygit/discussions/4666): Lumen integration
- [Issue #5744](https://github.com/jesseduffield/lazygit/issues/5744): Built-in Copilot commit message (đã đóng)
- [Discussion #5963](https://github.com/jesseduffield/lazygit/discussions/5963): AI commit message fork

---

## Font

| Font | Mô tả | Link |
|------|-------|------|
| **Maple Mono** ⭐ | Font chính — monospace, round corner, ligatures, Nerd-Font icons | [subframe7536/maple-font](https://github.com/subframe7536/maple-font) |
| JetBrains Mono | Typeface cho developer,ligatures | [JetBrains/JetBrainsMono](https://github.com/JetBrains/JetBrainsMono) |
| Cascadia Code | Monospace với ligatures, thiết kế cho Windows Terminal | [microsoft/cascadia-code](https://github.com/microsoft/cascadia-code) |
| FiraCode | Monospace miễn phí với programming ligatures | [tonsky/FiraCode](https://github.com/tonsky/FiraCode) |
| Monaspace | Superfamily fonts cho code (5 style: Antrova, Argon, Xenon, Neon, Radon) | [githubnext/monaspace](https://github.com/githubnext/monaspace) |
| Intel One Mono | Monospace từ Intel | [intel/intel-one-mono](https://github.com/intel/intel-one-mono) |
| Monocraft | Monospace lấy cảm hứng từ Minecraft typeface | [IdreesInc/Monocraft](https://github.com/IdreesInc/Monocraft) |
| Miracode | Phiên bản vector-y sắc nét của Monocraft | [IdreesInc/Miracode](https://github.com/IdreesInc/Miracode) |
| Comic Mono | Monospace dễ đọc, phong cách Comic Sans | [dtinth/comic-mono-font](https://github.com/dtinth/comic-mono-font) |
| Mona Sans | Variable font từ GitHub | [github/mona-sans](https://github.com/github/mona-sans) |
| Operator Code | Monospace với programming ligatures | [hanbalahmed/OperatorCode](https://github.com/hanbalahmed/OperatorCode) |

> **Nerd Fonts**: Tập hợp icon font cho terminal — https://www.nerdfonts.com/

> **Danh sách đầy đủ**: https://github.com/stars/huyhoang160593/lists/favoritefonts

---

Xem thêm: [CONTEXT.md](CONTEXT.md), [docs/adr](docs/adr/)
