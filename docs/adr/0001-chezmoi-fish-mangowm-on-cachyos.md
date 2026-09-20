---
status: accepted
date: 2026-09-20
---

# Dùng chezmoi + fish + mangowm trên CachyOS

Quản lý dotfile trên CachyOS bằng **chezmoi** làm trình quản lý source of truth, **fish** làm shell, và **mangowm** làm Wayland compositor, với **Noctalia** cung cấp desktop shell và login greeter.

## Lý do

Trong buổi grill, team đã giải quyết nhiều quyết định nền tảng khó đảo ngược:

1. **Chezmoi thay vì `cachyos-fish-config`.** Gói `cachyos-fish-config` override `config.fish` thủ công, cài thêm prompt không mong muốn, và định nghĩa abbreviation/function mâu thuẫn với thiết kế. Chezmoi giữ config chủ đạo trong git và áp dụng deterministically qua nhiều máy.

2. **Fish làm shell.** Fish hỗ trợ abbreviation (`abbr`), completion thông minh, và mô hình init rõ ràng (`conf.d/*.fish` → `config.fish`). Repo đã ghi best practices trong `docs/research/fish-config-best-practices.md` và dùng `starship init fish`, `zoxide init fish`, `fzf --fish`, cùng guard `ssh-agent` trong `config.fish`.

3. **mangowm làm Wayland compositor.** Compositor với animation mượt và config modular (`cfg/{monitors,keybinds,input,autostart,env,appearance,layout,misc,rules}.conf`). Quan trọng: mangowm **không** ship login greeter.

4. **Noctalia greeter thay SDDM.** Vì mangowm không có greeter, chọn `noctalia-greeter-session` thay SDDM. SDDM bị loại rõ ràng: màn hình đăng nhập không đồng bộ với giao diện Noctalia và sẽ lệch视觉 với bar, panel, và màn hình khóa mà Noctalia cung cấp. Noctalia cũng cung cấp bar, launcher, thông báo, wallpaper, và màn hình khóa nên toàn bộ bề mặt đồng bộ.

5. **Sửa env theme QT.** Sau cài đặt, `env.conf` của mangowm phải set `QT_QPA_PLATFORMTHEME=qt6ct` và `QT_QPA_PLATFORMTHEME_QT6=qt6ct` để Qt6 app nhận bảng màu Noctalia (cấu hình trong `~/.config/qt6ct/colors/noctalia.conf` và `~/.config/qt5ct/colors/noctalia.conf`). Nếu không, Qt app sẽ render theme lỗi/thiếu.

6. **Ghostty thay Alacritty; Helium thay Firefox.** Cả hai được ghi vào danh sách sửa sau cài đặt.

7. **Nhập liệu tiếng Việt qua fcitx5-lotus.** IM mặc định đặt là `lotus` với toggle `Alt+Space` trong `~/.config/fcitx5/config`.

## Các lựa chọn đã cân nhắc

| Lựa chọn | Bỏ qua vì |
|---|---|
| Dùng `cachyos-fish-config` | Override config chezmoi, prompt không mong muốn, command phản thiết kế |
| Dùng SDDM làm greeter | lệch视觉 với Noctalia shell; Noctalia Greeter cung cấp bề mặt đăng nhập đồng bộ |
| Bỏ qua sửa env QT trong mangowm | Qt6 app sẽ render theme lỗi |

## Hệ quả

- Repo dotfile phải chứa `.chezmoiignore.tmpl` để bỏ qua entry autostart IBus của CachyOS trên các desktop không phải COSMIC.
- `config.fish` giữ tối giản và portable; override riêng từng máy nằm trong chezmoi data directories hoặc conditional block, không nằm trong config do CachyOS ship.
- Sau mỗi lần cài CachyOS mới, checklist sau cài là: apply chezmoi → kiểm tra biến QT trong mangowm `env.conf` → validate config Noctalia → bật `fcitx5-lotus` → cấu hình `ufw` cho LocalSend.
- README nên là ghi chú thiết lập ngắn (không phải hướng dẫn CachyOS đầy đủ), ghi các yêu cầu theo thứ tự: OS → fish + chezmoi → apply chezmoi → sửa sau cài, với các pitfalls được nêu rõ.

## Xem thêm

- `CONTEXT.md` — glossary thuật ngữ
- `docs/research/fish-config-best-practices.md` — ghi chú research cấu hình fish
- `dot_config/private_fish/config.fish` — config fish chủ đạo trong repo dotfile
- `dot_config/mango/cfg/env.conf` — biến môi trường mangowm
- `dot_config/stellar/config.json` — trạng thái theme Stellar
- `.config/starship.toml` — cấu hình prompt Starship
