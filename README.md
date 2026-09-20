# Dotfiles — Thiết lập desktop mangowm bằng chezmoi

Repo này dùng chezmoi quản lý dotfile và thiết lập environment trên CachyOS + mangowm (Wayland compositor) + Noctalia (desktop shell).

## Yêu cầu cài đặt theo thứ tự
1. CachyOS (xem ghi chú bên dưới)
2. `fish` + `chezmoi` — shell & quản lý dotfile
3. Áp dụng chezmoi: `chezmoi init --apply huyhoang160593/dotfiles`
4. Các bước sửa sau cài đặt (xem từng phần bên dưới)

---

## Ghi chú cài đặt CachyOS

### Không dùng cachyos-fish-config
- **Lý do**: Gói `cachyos-fish-config` xung đột với `config.fish` do chezmoi quản lý, cài thêm prompt không mong muốn, và định nghĩa các abbreviation/function mâu thuẫn với thiết kế dự kiến.
- **Cách sửa**: Bỏ chọn gói `cachyos-fish-config` khi cài đặt CachyOS (hoặc gỡ nếu đã cài).

### Window Manager: mangowm
- **Đã chọn**: mangowm
- **Đã bỏ chọn**: ❌ SDDM (login manager) — dùng Noctalia Greeter thay thế để đồng bộ giao diện
- **Sửa sau cài**: Chỉnh `~/.config/mango/cfg/env.conf` để set `QT_QPA_PLATFORMTHEME=qt6ct` và `QT_QPA_PLATFORMTHEME_QT6=qt6ct`

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
| Prompt | Starship + Stella (quản lý theme) | Prompt đa nền tảng; Stella quản lý theme | Bảng màu rose-pine; áp dụng với `stella` |
| WM | mangowm | Wayland compositor | Config trong `~/.config/mango/cfg/` |
| Desktop Shell | Noctalia | Thanh trạng thái, panel, launcher, thông báo, màn hình khóa | |
| Greeter | Noctalia Greeter | Màn hình đăng nhập (không dùng SDDM) | |
| Dashboard TUI | Fresh | Dashboard terminal | |
| Quản lý session | Zellij | Tab, pane, layout cho terminal | |
| AI | Ante | Lightweight, ít lỗi hơn Claude Code/Codex | |
| Quản lý AppImage | AppManager | Cài đặt và quản lý AppImage | Dùng `appimage_update_icon` để sửa icon |
| CLI tiện ích | fzf, zoxide, eza, tealdeer, bat | Fuzzy finder, nhảy thư mục, ls replacement, tldr, cat replacement | eza dùng `--icons` |
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

### Icon AppImage bị hỏng
- **Sự cố**: Icon không hiển thị trong launcher/menu desktop sau khi tích hợp AppManager.
- **Nguyên nhân**: Icon đặt sai thư mục hicolor; cache GTK/desktop chưa được làm mới.
- **Cách sửa**: Chạy function fish `appimage_update_icon`:
  ```fish
  appimage_update_icon
  ```
  Hoặc script tự chạy khi cài AppImage mới qua AppManager.

### Starship hiển thị prompt mặc định
- **Sự cố**: Starship prompt chưa được áp dụng theme stella.
- **Cách sửa**:
  ```fish
  stella apply rose-pine@1.0  # hoặc theme của bạn
  exec fish  # tải lại
  ```

---

## Biến môi trường cần kiểm tra
- [ ] `QT_QPA_PLATFORMTHEME=qt6ct` trong mangowm env.conf
- [ ] `QT_QPA_PLATFORMTHEME_QT6=qt6ct` trong mangowm env.conf

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

## TODO / Backlog
- [x] Viết `CONTEXT.md` glossary
- [x] Viết `docs/adr/0001-chezmoi-fish-mangowm-on-cachyos.md`
- [x] Viết document ufw firewall rule cho LocalSend (xem bên trên)

---

Xem thêm: [CONTEXT.md](CONTEXT.md), [docs/adr](docs/adr/)
