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

### Validate Config Noctalia
- Config: `~/.config/noctalia/*.toml` (định dạng TOML)
- Validate: `noctalia config validate`
- Docs: https://docs.noctalia.dev/noctalia/configuration/

### Nhập liệu tiếng Việt
- Cài `fcitx5-lotus`
- Xem hướng dẫn cài đặt chi tiết cho từng hệ điều hành tại: https://lotusinputmethod.github.io/#installation
- Cài xong, set default IM thành `lotus` với toggle `Alt+Space` trong `~/.config/fcitx5/config`

---

## Bộ công cụ

| Hạng mục | Công cụ | Mô tả | Ghi chú / Fix |
|---|---|---|---|
| Terminal | Ghostty | Terminal emulator nhanh, hỗ trợ GPU rendering, minimalist UI | Thay thế Alacritty |
| Trình duyệt | Helium | Trình duyệt nhẹ, chạy dạng AppImage | Quản lý bởi AppManager |
| Shell | fish | Shell chính; tất cả function viết cho fish, không phải bash | |
| Prompt | Starship + Stellar (quản lý theme) | Prompt đa nền tảng; Stellar quản lý theme | Bảng màu rose-pine; áp dụng với `stellar` |
| WM | mangowm | Wayland compositor | Config trong `~/.config/mango/cfg/` |
| Desktop Shell | Noctalia | Thanh trạng thái, panel, launcher, thông báo, màn hình khóa | |
| Greeter | Noctalia Greeter | Màn hình đăng nhập (không dùng SDDM) | |
| Dashboard TUI | Fresh | Dashboard terminal | |
| Quản lý session | Zellij | Tab, pane, layout cho terminal | |
| AI | Ante | Lightweight, ít lỗi hơn Claude Code/Codex | |
| Quản lý AppImage | AppManager | Cài đặt và quản lý AppImage | Dùng `appimage_update_icon` để sửa icon |
| CLI tiện ích | fzf, zoxide, eza, tealdeer, bat | Fuzzy finder, nhảy thư mục, ls replacement, tldr, cat replacement | eza dùng `--icons=auto` |
| System info | fastfetch | Hiển thị thông tin hệ thống khi mở shell | Preset `examples/12.jsonc` |
| Git TUI | lazygit | Giao diện terminal cho git | Commit, diff, stash, merge trực quan |
| Đồng bộ web | Koonde + Proton Pass | Bookmark, mật khẩu | |
| Firewall | ufw | Mở port cho LocalSend | Xem phần ufw bên dưới |

---

## Các sự cố đã biết & Cách sửa

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
- **Nguyên nhân**: Icon đặt sai thư mục hicolor; cache GTK/desktop chưa được làm mới.
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

### Starship hiển thị prompt mặc định
- **Sự cố**: Starship prompt chưa được áp dụng theme stellar.
- **Cách sửa**:
  ```fish
  stellar apply rose-pine@1.0  # hoặc theme của bạn
  exec fish  # tải lại
  ```

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

## Fish custom functions

Các function fish do chezmoi quản lý, đặt tại `~/.config/fish/private_functions/`:

| Function | Mô tả | Cách dùng |
|---|---|---|
| `appimage_update_icon` | Di chuyển icon PNG từ `~/.local/share/icons/` về `hicolor/256x256/apps/`, cập nhật GTK icon cache & desktop database | `appimage_update_icon` |
| `check_tools` | Kiểm tra tất cả tool trong bộ công cụ đã cài đặt chưa, liệt kê cái còn thiếu | `check_tools` |
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
